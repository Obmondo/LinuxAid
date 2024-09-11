require 'spec_helper'

describe 'curator::action', type: :define do
  let(:title) { 'myjob' }
  let(:pre_condition) { 'include curator' }

  context 'invalid command' do
    let(:params) { { action: 'invalid' } }

    it { is_expected.to raise_error(Puppet::Error) }
  end

  context 'port is valid' do
    let(:params) { { port: 'string' } }

    it { is_expected.to raise_error(Puppet::Error) }
  end
end
