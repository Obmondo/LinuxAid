require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/reboot/posix'

describe Puppet::Type.type(:reboot).provider(:posix) do
  let(:resource) { Puppet::Type.type(:reboot).new(provider: :posix, name: 'posix_reboot') }
  let(:provider) { resource.provider }

  it 'is an instance of Puppet::Type::Reboot::ProviderPosix' do
    provider.must be_an_instance_of Puppet::Type::Reboot::ProviderPosix
  end

  context 'self.instances' do
    it 'returns an empty array' do
      provider.class.instances.should == []
    end
  end

  context 'when checking if the `when` property is insync' do
    it 'is absent by default' do
      expect(provider.when).to eq(:absent)
    end

    it 'does not reboot when setting the `when` property to refreshed' do
      provider.expects(:reboot).never

      provider.when = :refreshed
    end
  end

  context 'when a reboot is triggered', if: Puppet::Util.which('shutdown') do
    before :each do
      provider.expects(:async_shutdown).with(includes('shutdown')).at_most_once
    end

    it 'stops the application by default' do
      Puppet::Application.expects(:stop!)
      provider.reboot
    end

    it 'cancels the rest of the catalog transaction if apply is set to immediately' do
      resource[:apply] = :immediately
      Puppet::Application.expects(:stop!)
      provider.reboot
    end

    it "doesn't stop the rest of the catalog transaction if apply is set to finished" do
      resource[:apply] = :finished
      Puppet::Application.expects(:stop!).never
      provider.reboot
    end

    context 'on Solaris' do
      before :each do
        Facter.stubs(:value).with(:kernel).returns('SunOS')
      end

      it 'includes the pre-confirmation flag' do
        provider.expects(:async_shutdown).with(includes('-y'))
        provider.reboot
      end

      it 'includes the init-state 6 flag' do
        provider.expects(:async_shutdown).with(includes('-i 6'))
        provider.reboot
      end

      it 'includes a timeout in the future' do
        provider.expects(:async_shutdown).with(includes("-g #{resource[:timeout].to_i}"))
        provider.reboot
      end

      it 'accepts timeouts that are not multiples of 60' do
        resource[:timeout] = 61
        Puppet.expects(:warning).with(includes('rounding')).never
        provider.expects(:async_shutdown).with(includes("-g #{resource[:timeout].to_i}"))
        provider.reboot
      end
    end

    context 'on other systems' do
      before :each do
        Facter.stubs(:value).with(:kernel).returns('Linux')
      end

      it 'includes the restart flag' do
        provider.expects(:async_shutdown).with(includes('-r'))
        provider.reboot
      end

      it 'includes a timeout in the future' do
        provider.expects(:async_shutdown).with(includes("+#{(resource[:timeout].to_i / 60.0).ceil}"))
        provider.reboot
      end

      it 'rounds up and provides a warning if the timeout is not a multiple of 60' do
        resource[:timeout] = 61
        Puppet.expects(:warning).with(includes('rounding'))
        provider.expects(:async_shutdown).with(includes("+#{(resource[:timeout].to_i / 60.0).ceil}"))
        provider.reboot
      end
    end

    it 'includes the quoted reboot message' do
      resource[:message] = 'triggering a reboot'
      provider.expects(:async_shutdown).with(includes('"triggering a reboot"'))
      provider.reboot
    end
  end
end
