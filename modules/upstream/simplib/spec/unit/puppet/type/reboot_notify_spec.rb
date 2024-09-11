#!/usr/bin/env rspec

require 'spec_helper'

reboot_notify_type = Puppet::Type.type(:reboot_notify)

describe reboot_notify_type do
  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Reboot_notify.any_instance.stubs(:catalog).returns(@catalog)
  end

  context 'when setting parameters' do
    it 'should accept a name parameter' do
      resource = reboot_notify_type.new :name => 'foo', :reason => 'Foo needs a reboot!'
      expect(resource[:name]).to eq('foo')
    end

    it 'should accept a reason parameter' do
      resource = reboot_notify_type.new :name => 'foo', :reason => 'Foo needs a reboot!'
      expect(resource[:reason]).to eq('Foo needs a reboot!')
    end

    it 'should accept a log_level parameter' do
      resource = reboot_notify_type.new :name => 'foo', :log_level => 'warning'
      expect(resource[:log_level]).to eq('warning')
    end

    it 'should accept a control_only parameter' do
      resource = reboot_notify_type.new :name => 'foo', :control_only => true
      expect(resource[:control_only]).to eq(true)
    end

    it 'should raise an error if another resource has a control_only parameter' do
      resource = reboot_notify_type.new :name => 'foo', :control_only => true
      @catalog.add_resource(resource)

      expect {
        reboot_notify_type.new :name => 'bar', :control_only => true
      }.to raise_error(/You can only have one reboot_notify.*Conflicting resource found in file.* on line/m)
    end
  end
end

