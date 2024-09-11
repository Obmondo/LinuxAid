require 'spec_helper'

describe 'simplib::validate_between' do
  context 'validates input contained in range' do
    it { is_expected.to run.with_params('-1',-3, 0) }
    it { is_expected.to run.with_params(7, 0, 60) }
    it { is_expected.to run.with_params(7.6, 7.1, 8.4) }
  end

  context 'rejects input not contained in range' do
    it do
      is_expected.to run.with_params('-1', 0, 3).and_raise_error(
       /'-1' is not between '0' and '3'/ )
    end

    it do
      is_expected.to run.with_params(0, 1, 60).and_raise_error(
       /'0' is not between '1' and '60'/ )
    end

    it do
      is_expected.to run.with_params(7.6, 7.7, 8.4).and_raise_error(
       /'7.6' is not between '7.7' and '8.4'/ )
    end
  end
end
