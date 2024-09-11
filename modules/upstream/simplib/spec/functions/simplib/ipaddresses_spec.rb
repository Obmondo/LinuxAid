#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::ipaddresses' do
  shared_examples_for 'a host' do
    before(:each) do
      @result = subject.execute
    end

    it 'should return an Array' do
      expect(@result.is_a?(Array)).to be true
    end

    it 'should return an Array with no nil values' do
      expect(@result.include?(nil)).to_not be true
    end

    it 'should return an Array with no empty values' do
      expect(@result.include?(/^(\S*)$/)).to_not be true
    end
  end

  # Mock out the Facts
  context "All Interfaces Have IP Addresses" do
    let(:facts) {{
      :interfaces     => 'eth0,eth1,lo',
      :ipaddress_eth0 => '1.2.3.4',
      :ipaddress_eth1 => '5.6.7.8',
      :ipaddress_lo   => '127.0.0.1'
    }}

    it_behaves_like 'a host'
  end

  context "All Interfaces Do Not Have IP Addresses" do
    let(:facts) {{
      :interfaces     => 'eth0,eth1,lo',
      :ipaddress_eth0 => '1.2.3.4',
      :ipaddress_lo   => '127.0.0.1'
    }}

    it_behaves_like 'a host'
  end

  context "The system has no interfaces" do
    let(:facts) {{ }}

    it 'should not raise an error' do
      expect{ subject.execute }.to_not raise_error
    end
  end
end
