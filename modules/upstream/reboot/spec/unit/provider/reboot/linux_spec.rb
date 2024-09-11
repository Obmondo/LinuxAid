require 'spec_helper'
require 'puppet/type'
require 'puppet/provider/reboot/linux'
require 'puppet/provider/reboot/posix'

describe Puppet::Type.type(:reboot).provider(:linux) do
  let(:resource) { Puppet::Type.type(:reboot).new(provider: :linux, name: 'linux_reboot') }
  let(:provider) { resource.provider }

  it 'is an instance of Puppet::Type::Reboot::ProviderLinux' do
    provider.must be_an_instance_of Puppet::Type::Reboot::ProviderLinux
  end

  it 'is a kind of Puppet::Type::Reboot::ProviderPosix' do
    provider.must be_a_kind_of Puppet::Type::Reboot::ProviderPosix
  end

  context '#initialize' do
    it 'issues a deprecation warning' do
      Puppet.expects(:deprecation_warning).with("The 'linux' reboot provider is deprecated and will be removed; use 'posix' instead.")

      Puppet::Type.type(:reboot).new(provider: :linux, name: 'linux_reboot')
    end
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
      Facter.stubs(:value).with(:kernel).returns('Linux')
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

    it 'includes the quoted reboot message' do
      resource[:message] = 'triggering a reboot'
      provider.expects(:async_shutdown).with(includes('"triggering a reboot"'))
      provider.reboot
    end
  end
end
