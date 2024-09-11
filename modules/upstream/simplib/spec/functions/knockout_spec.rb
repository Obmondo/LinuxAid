require 'spec_helper'

shared_examples 'simplib::knockout()' do |input_array, return_value|
  it { is_expected.to run.with_params(input_array).and_return(return_value) }
end

describe 'simplib::knockout' do
  context 'when a simple array is passed' do
    it_behaves_like 'simplib::knockout()',
                    %w(socrates plato aristotle),
                    %w(socrates plato aristotle)
  end

  context 'when passed a mixed array' do
    it_behaves_like 'simplib::knockout()',
                    %w(socrates plato aristotle --socrates),
                    %w(plato aristotle)
  end

  context 'when passed a mixed array where everything is knocked out' do
    it_behaves_like 'simplib::knockout()',
                    %w(socrates plato aristotle --plato --aristotle --socrates),
                    []
  end
end
