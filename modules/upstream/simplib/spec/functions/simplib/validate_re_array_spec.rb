require 'spec_helper'

describe 'simplib::validate_re_array' do

  context 'with valid inputs' do
    it 'validates a string against a string' do
      is_expected.to run.with_params('one', '^one$')
    end

    it 'validates a string against an array' do
      is_expected.to run.with_params('one5', ['^one[0-9]+', '^two[0-9]+'])
    end

    it 'validates an array against a string' do
      is_expected.to run.with_params(['none', 'no one'], 'one$')
    end

    it 'validates an array against an array' do
      is_expected.to run.with_params(['one-a', 'one-b'], ['^one', '^two'])
    end
  end

  context 'with invalid inputs' do
    it 'rejects a string against a string' do
      is_expected.to run.with_params(' one','^one$').and_raise_error(
        /" one" does not match \["\^one\$"\]/ )
    end

    it 'rejects a string against a string with a custom message' do
      is_expected.to run.with_params(' one','^one$', 'this is not the one').and_raise_error(
        /this is not the one/ )
    end

    it 'rejects a string against an array' do
      is_expected.to run.with_params('oneA',['^one[0-9]', '^one[a-z]']).and_raise_error(
        /"oneA" does not match \["\^one\[0-9\]", "\^one\[a-z\]"]/ )
    end

    it 'rejects a string against an array with a custom message' do
      is_expected.to run.with_params('oneA',['^one[0-9]', '^one[a-z]', 'malformed one config']).and_raise_error(
        /malformed one config/ )
    end

    it 'rejects an array against a string' do
      is_expected.to run.with_params(['none', 'no one'], 'all').and_raise_error(
        /"none" does not match \["all"\]/ )
    end

    it 'rejects an array against a string with a custom message' do
      is_expected.to run.with_params(['none', 'no one'], 'all', 'this is not all').and_raise_error(
        /this is not all/ )
    end

    it 'rejects an array against an array' do
      is_expected.to run.with_params(['none', 'no one'], ['all', 'every']).and_raise_error(
        /"none" does not match \["all", "every"\]/ )
    end

    it 'rejects an array against an array with a custom message' do
      is_expected.to run.with_params(['none', 'no one'], ['all', 'every'], 'this is not all').and_raise_error(
        /this is not all/ )
    end
  end
end
