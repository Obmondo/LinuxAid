require 'spec_helper'

describe 'simplib::validate_bool' do
  context 'with single input' do
    describe 'accepts valid input' do
      it { is_expected.to run.with_params(true) }
      it { is_expected.to run.with_params('true') }
      it { is_expected.to run.with_params(false) }
      it { is_expected.to run.with_params('false') }
    end

    describe 'rejects invalid input' do
      it do
        is_expected.to run.with_params('True').and_raise_error(
         /'True' is not a boolean/ )
      end

      it do
        is_expected.to run.with_params('FALSE').and_raise_error(
         /'FALSE' is not a boolean/ )
      end
    end
  end

  context 'with multiple inputs' do
    describe 'accepts valid input' do
      it { is_expected.to run.with_params(true, 'true', false, 'false') }
    end

    describe 'rejects invalid input' do
      it do
        is_expected.to run.with_params(true, 'TRUE', false, 'false').and_raise_error(
         /'TRUE' is not a boolean/ )
      end
    end
  end
end
