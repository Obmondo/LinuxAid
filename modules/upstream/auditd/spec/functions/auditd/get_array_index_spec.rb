require 'spec_helper'

describe 'auditd::get_array_index' do
  let(:test_array) { ['elemA', 'elemB', 'elemC'] }
  let(:long_test_array) {
    array = []
    (0..99).each { |num| array << "elem#{num}" }
    array
  }

  it 'returns the index 0-padded to 2 digits, when num_digits is not specified' do
    is_expected.to run.with_params('elemA', test_array).and_return('00')
  end

  it 'returns the index 0-padded to num_digits' do
    is_expected.to run.with_params('elemB', test_array, 4).and_return('0001')
  end

  it 'returns the index without padding when length exceeds num_digits' do
    is_expected.to run.with_params('elem86', long_test_array, 1).and_return('86')
  end

  it 'returns the 1st index when the element appears more than once' do
    dup_array = ['elemA', 'elemA', 'elemA']
    is_expected.to run.with_params('elemA', dup_array).and_return('00')
  end

  it 'fails when the element is not in the array' do
    expect { is_expected.to run.with_params('elemX', test_array) }.to raise_error(
      /auditd::get_array_index: elemX is not found in/)
  end

end

