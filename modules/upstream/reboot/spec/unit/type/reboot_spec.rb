require 'spec_helper'
require 'puppet/type'
require 'puppet/type/reboot'

describe Puppet::Type.type(:reboot) do
  let(:resource) { Puppet::Type.type(:reboot).new(name: 'reboot') }
  let(:provider) { Puppet::Provider.new(resource) }

  before :each do
    resource.provider = provider
    resource.class.rebooting = false
  end

  it 'is an instance of Puppet::Type::Reboot' do
    resource.must be_an_instance_of Puppet::Type::Reboot
  end

  context 'when refreshed' do
    it 'onlies reboot if the `when` parameter is `refreshed`' do
      resource[:when] = :refreshed
      resource.provider.expects(:reboot)

      resource.refresh
    end

    it 'does not reboot if the `when` parameter is `pending`' do
      resource.provider.expects(:satisfies?).with([:manages_reboot_pending]).returns(true)
      resource.provider.expects(:reboot).never
      resource[:when] = :pending

      resource.refresh
    end
  end

  context 'parameter :when' do
    it 'defaults to :refreshed' do
      resource[:when].must == :refreshed
    end

    it 'accepts :pending' do
      resource.provider.expects(:satisfies?).with([:manages_reboot_pending]).returns(true)

      resource[:when] = :pending
    end

    it 'rejects other values' do
      expect {
        resource[:when] = :whenever
      }.to raise_error(Puppet::ResourceError, %r{Invalid value :whenever. Valid values are refreshed})
    end
  end

  context 'parameter :apply' do
    it 'defaults to :immediately' do
      resource[:apply].must == :immediately
    end

    it 'accepts :finished' do
      resource[:apply] = :finished
    end

    it 'rejects other values' do
      expect {
        resource[:apply] = :whenever
      }.to raise_error(Puppet::ResourceError, %r{Invalid value :whenever. Valid values are immediately})
    end
  end

  context 'parameter :message' do
    it 'defaults to "Puppet is rebooting the computer"' do
      resource[:message].must == 'Puppet is rebooting the computer'
    end

    it 'accepts a custom message' do
      resource[:message] = 'This is a different message'
    end

    it 'rejects an empty value' do
      expect {
        resource[:message] = ''
      }.to raise_error(Puppet::ResourceError, %r{A non-empty message must be specified.})
    end

    it 'accepts a 8000 character message' do
      resource[:message] = 'a' * 8000
    end

    it 'rejects a 8001 character message' do
      expect {
        resource[:message] = 'a' * 8001
      }.to raise_error(Puppet::ResourceError, %r{The given message must not exceed 8000 characters.})
    end

    it 'is logged on reboot' do
      resource[:message] = 'Custom message'
      logmessage = 'Scheduling system reboot with message: "Custom message"'
      Puppet.expects(:notice).with(logmessage)
      resource.provider.expects(:reboot)
      resource.refresh
    end
  end

  context 'parameter :timeout' do
    it 'defaults :timeout to 60 seconds' do
      resource[:timeout].must == 60
    end

    it 'accepts 30 minute timeout' do
      resource[:timeout] = 30 * 60
    end

    ['later', :later, {}, [], true].each do |timeout|
      it "should reject a non-integer (#{timeout.class}) value" do
        expect {
          resource[:timeout] = timeout
        }.to raise_error(Puppet::ResourceError, %r{The timeout must be an integer})
      end
    end
  end

  context 'parameter :onlyif' do
    it 'defaults :onlyif to nil' do
      resource[:onlyif].must.nil?
    end

    it 'accepts package_installer reason array' do
      resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
      resource[:onlyif] = [:package_installer]
    end

    it 'accepts package_installer reason' do
      resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
      resource[:onlyif] = :package_installer
    end

    it 'does not accept an empty list' do
      expect {
        resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
        resource[:onlyif] = []
      }.to raise_error(Puppet::ResourceError, %r{There must be at least one element in the list})
    end

    ['pks_install', :pkg_install, {}, true].each do |reason|
      it "should reject invalid reasons (#{reason})" do
        expect {
          resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
          resource[:onlyif] = reason
        }.to raise_error(Puppet::ResourceError, %r{value must be one of})
      end
    end
  end

  context 'parameter :unless' do
    it 'defaults :timeout to nil' do
      resource[:unless].must.nil?
    end

    it 'accepts package_installer reason array' do
      resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
      resource[:unless] = [:package_installer]
    end

    it 'accepts package_installer reason' do
      resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
      resource[:unless] = :package_installer
    end

    it 'does not accept an empty list' do
      expect {
        resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
        resource[:unless] = []
      }.to raise_error(Puppet::ResourceError, %r{There must be at least one element in the list})
    end

    ['pks_install', :pkg_install, {}, true].each do |reason|
      it "should reject invalid reasons (#{reason})" do
        expect {
          resource.provider.class.expects(:satisfies?).with(:manages_reboot_pending).returns(true)
          resource[:unless] = reason
        }.to raise_error(Puppet::ResourceError, %r{value must be one of})
      end
    end
  end

  context 'multiple reboot resources' do
    let(:resource2) { Puppet::Type.type(:reboot).new(name: 'reboot2') }
    let(:provider2) { Puppet::Provider.new(resource2) }

    before :each do
      resource2.provider = provider2
    end

    it 'onlies reboot once even if more than one triggers' do
      resource[:apply] = :finished
      resource[:when] = :refreshed
      resource.provider.expects(:reboot)
      resource.refresh

      resource2[:apply] = :finished
      resource2[:when] = :refreshed
      resource2.provider.expects(:reboot).never
      Puppet.expects(:debug).with(includes('already scheduled'))
      resource2.refresh
    end
  end
end
