#!/usr/bin/env rspec

require 'spec_helper'

init_ulimit_type = Puppet::Type.type(:init_ulimit)

describe init_ulimit_type do
  before(:each) do
    @catalog = Puppet::Resource::Catalog.new
    Puppet::Type::Reboot_notify.any_instance.stubs(:catalog).returns(@catalog)
  end

  context 'when setting parameters' do
    it 'should accept valid input' do
      resource = init_ulimit_type.new(
        :name       => 'foo',
        :target     => 'foo_svc',
        :limit_type => 'both',
        :item       => 'max_nice',
        :value      => '10'
      )
      expect(resource[:name]).to eq('foo')
      expect(resource[:item]).to eq('e')
    end

    it 'should accept composite namevars' do
      resource = init_ulimit_type.new(
        :name       => 'v|foo_svc',
        :limit_type => 'both',
        :value      => '10'
      )
      expect(resource[:name]).to eq('v|foo_svc')
      expect(resource[:item]).to eq('v')
      expect(resource[:target]).to eq('foo_svc')
    end

    it 'should translate "unlimited" for "max_open_files"' do
      resource = init_ulimit_type.new(
        :name       => 'foo',
        :target     => 'foo_svc',
        :item       => 'max_open_files',
        :value      => 'unlimited'
      )
      expect(resource[:name]).to eq('foo')
      expect(resource[:item]).to eq('n')
      expect(resource[:value]).to eq('1048576')
    end
  end
end
