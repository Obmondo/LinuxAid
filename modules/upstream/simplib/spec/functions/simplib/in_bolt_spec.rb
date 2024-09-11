require 'spec_helper'

describe 'simplib::in_bolt' do
  context 'when not in a bolt environment' do
    it { is_expected.to run.and_return(false) }
  end

  context 'when in a bolt environment' do
    let(:environment) { 'bolt_catalog' }

    it { is_expected.to run.and_return(true) }
  end
end
