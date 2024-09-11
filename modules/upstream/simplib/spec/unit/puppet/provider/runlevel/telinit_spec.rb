require 'spec_helper'

describe Puppet::Type.type(:runlevel).provider(:telinit) do
  let(:resource) {
    Puppet::Type.type(:runlevel).new( name: '5')
  }
  let(:provider) {
    Puppet::Type.type(:runlevel).provider(:telinit).new(resource)
  }

  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Runlevel.any_instance.stubs(:catalog).returns(@catalog)

    described_class.stubs(:command).with(:telinit).returns('/sbin/telinit')
  end

  context '#level' do
    it 'should return the runlevel' do
      Facter.stubs(:value).with(:runlevel).returns('5')
      Facter.stubs(:value).with(Not(equals(:runlevel)))

      expect(provider.level).to eq('5')
    end
  end

  context '#level=' do
    context 'with a normal transition' do
      it 'should succeed' do
        provider.expects(:execute).with(['/sbin/telinit', resource[:level]])

        provider.level=(resource[:level])
      end
    end

    context 'with a timeout' do
      it 'should raise an exception' do
        provider.expects(:execute).with(['/sbin/telinit', resource[:level]]).raises(Timeout::Error)

        expect { provider.level=(resource[:level]) }.to raise_error(/Could not transition to runlevel/)
      end
    end

    context 'persisting state' do
      before(:each) do
        require 'tempfile'

        @tempfile = Tempfile.new("#{described_class}")
      end

      after(:each) do
        FileUtils.rm(@tempfile)
      end

      context '#persist' do
        it 'returns :true if in sync' do
          @tempfile.write("id:#{resource[:level]}:initdefault:nil\n")
          @tempfile.rewind

          File.expects(:open).with('/etc/inittab', 'r').returns(@tempfile)
          File.stubs(:open).with(Not(equals(['/etc/inittab', 'r'])))

          expect(provider.persist).to eq(:true)
        end

        it 'returns :false if not in sync' do
          @tempfile.write('')
          @tempfile.rewind

          File.expects(:open).with('/etc/inittab', 'r').returns(@tempfile)
          File.stubs(:open).with(Not(equals(['/etc/inittab', 'r'])))

          expect(provider.persist).to eq(:false)
        end
      end

      context '#persist=' do
        it 'sets the system default runlevel' do
          @tempfile.write("id:#{resource[:level]}:initdefault:nil\n")
          @tempfile.rewind

          File.expects(:open).with('/etc/inittab', 'r').returns(@tempfile)
          File.stubs(:open).with(Not(equals(['/etc/inittab', 'r'])))

          fh = IO.open(IO.sysopen(@tempfile, 'w'), 'w')

          File.expects(:open).with('/etc/inittab', 'w').returns(fh)

          provider.persist=(resource[:level])

          expect(File.read(@tempfile)).to eq("id:#{resource[:level]}:initdefault:nil\n")
        end
      end
    end
  end
end
