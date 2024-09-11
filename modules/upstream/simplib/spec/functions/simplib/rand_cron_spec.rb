#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::rand_cron' do
  context "with a non-IP modifier and 'sha256'" do
    it { is_expected.to run.with_params('myhost.test.local', 'sha256').and_return([9]) }
  end

  context "with an IPv4 modifier and 'sha256'" do
    it { is_expected.to run.with_params('10.0.10.154','sha256').and_return([5]) }
  end

  context "with an IPv6 modifier and 'sha256'" do
    it { is_expected.to run.with_params('2001:0db8:85a3:0000:0000:8a2e:0370:7395','sha256').and_return([18]) }
  end

  context "with an IPv4 modifier and 'ip_mod'" do
    it { is_expected.to run.with_params('10.0.10.154','ip_mod').and_return([54]) }
  end

  context "with an IPv6 modifier and 'ip_mod'" do
    it { is_expected.to run.with_params('2001:0db8:85a3:0000:0000:8a2e:0370:7395','ip_mod').and_return([9]) }
  end

  context "with an invalid IP address and 'ip_mod'" do
    # matching legacy behavior, uses crc32 algorithm, instead
    it { is_expected.to run.with_params('300.0.20.35','ip_mod').and_return([17]) }
  end

  context "with 'crc32'" do
    it { is_expected.to run.with_params('myhost.test.local','crc32').and_return([32]) }
  end

  context 'with occurs specified' do
    it { is_expected.to run.with_params('10.0.10.154','sha256',2).and_return([5,35]) }
  end

  context 'with occurs and max_value specified' do
    it { is_expected.to run.with_params('10.0.10.154','sha256',2,23).and_return([5,17]) }
  end

end
