#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::ip_to_cron' do
  let(:facts) {{ :ipaddress => '10.0.10.154' }}

  context 'with default parameters' do
    it { is_expected.to run.with_params().and_return([54]) }
  end

  context 'occurs specified' do
    it { is_expected.to run.with_params(2).and_return([24,54]) }
  end

  context 'occurs and max_value specified' do
    it { is_expected.to run.with_params(2,23).and_return([6,18]) }
  end

  context 'occurs, max_value, and algorithm specified' do
    it { is_expected.to run.with_params(2,23,'sha256').and_return([5,17]) }
  end

  context 'occurs, max_value, algorithm, and IPv4 specified' do
    it { is_expected.to run.with_params(2,23,'sha256', '10.0.20.35').and_return([4,16]) }
  end

  context 'occurs, max_value, algorithm, and IPv6 specified' do
    it { is_expected.to run.with_params(2,23,'sha256','2001:0db8:85a3:0000:0000:8a2e:0370:7395').and_return([6,18]) }
  end

  context 'invalid ip specified' do
    it { is_expected.to run.with_params(2,23,'sha256', '300.0.20.35').and_raise_error(ArgumentError) }
  end
end
