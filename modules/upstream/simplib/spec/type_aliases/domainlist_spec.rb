require 'spec_helper'

describe 'Simplib::Domainlist' do
  context 'with valid DNS domain names' do
    it { is_expected.to allow_value(['test.com','test','t.','0.t-t.0.t','0-0.0-0'])}
    it { is_expected.to allow_value(['0-0'])}
  end

  context 'with invalid DNS domain names' do
    it { is_expected.not_to allow_value(['test.com','test','t','test-.com'])}
    it { is_expected.not_to allow_value(['-test'])}
    it { is_expected.not_to allow_value(['t.t.t.t.0', 'test.com'])}
  end
end

