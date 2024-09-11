require 'spec_helper'

describe 'simplib::caller' do
  # There's not much we can do besides this outside of an acceptance test but
  # this can at least identify syntax errors, etc...

  it { is_expected.to run.and_return('TOPSCOPE') }

  context 'with depth 0' do
    it { is_expected.to run.with_params(0).and_return('TOPSCOPE') }
  end
end
