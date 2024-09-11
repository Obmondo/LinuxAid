require 'spec_helper'

describe Puppet::Type.type(:runlevel).provider(:systemd) do
  let(:resource) {
    Puppet::Type.type(:runlevel).new( name: '5')
  }
  let(:provider) {
    Puppet::Type.type(:runlevel).provider(:systemd).new(resource)
  }

  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Runlevel.any_instance.stubs(:catalog).returns(@catalog)

    described_class.stubs(:command).with(:systemctl).returns('/usr/bin/systemctl')
    described_class.stubs(:command).with(:pgrep).returns('/bin/pgrep')
    Facter.stubs(:value).with(:kernel).returns('Linux')
  end

  context '#level' do
    it 'should return the runlevel' do
      Facter.stubs(:value).with(:runlevel).returns('5')

      expect(provider.level).to eq('5')
    end
  end

  context '#level_insync?' do
    context 'with a normal transition' do
      context 'when in sync' do
        it 'should run without a warning' do
          provider.expects(:execute).with(['/bin/pgrep', '-f', %{^(/usr/bin/)?systemctl[[:space:]]+isolate}], :failonfail => false).returns("\n")
          Puppet.expects(:warning).never

          expect(provider.level_insync?('5','5')).to be true
        end
      end

      context 'when out of sync' do
        it 'should run without a warning' do
          provider.expects(:execute).with(['/bin/pgrep', '-f', %{^(/usr/bin/)?systemctl[[:space:]]+isolate}], :failonfail => false).returns("\n")
          Puppet.expects(:warning).never

          expect(provider.level_insync?('3','5')).to be false
        end
      end
    end

    context 'with a systemctl isolation already running' do
      it 'should emit a warning' do
        provider.expects(:execute).with(['/bin/pgrep', '-f', %{^(/usr/bin/)?systemctl[[:space:]]+isolate}], :failonfail => false).returns("1234 systemctl isolate multi-user.target\n")
        Puppet.expects(:warning)

        expect(provider.level_insync?('5','3')).to be true
      end
    end
  end

  context '#level=' do
    context 'with a normal transition' do
      it 'should succeed' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'isolate', 'graphical.target'])

        provider.level=(resource[:level])
      end
    end

    context 'with a timeout' do
      it 'should raise an exception' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'isolate', 'graphical.target']).raises(Timeout::Error)

        expect { provider.level=(resource[:level]) }.to raise_error(/Could not transition to runlevel/)
      end
    end

    context '#persist' do
      it 'returns :true if in sync' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'get-default']).returns('graphical.target')

        expect(provider.persist).to eq(:true)
      end

      it 'returns :false if not in sync' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'get-default']).returns('3')

        expect(provider.persist).to eq(:false)
      end
    end

    context '#persist=' do
      it 'sets the system default runlevel' do
        provider.expects(:execute).with(['/usr/bin/systemctl', 'set-default', 'graphical.target'])

        provider.persist=(resource[:level])
      end
    end
  end
end
