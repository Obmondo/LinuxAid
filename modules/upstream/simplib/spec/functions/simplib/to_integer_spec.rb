#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::to_integer' do
  context 'should return converted value when conversion is possible' do
    it { is_expected.to run.with_params(12).and_return(12) }
    it { is_expected.to run.with_params('12').and_return(12) }
    it { is_expected.to run.with_params(12.1).and_return(12) }
    it { is_expected.to run.with_params(' 12.1 ').and_return(12) }

    # behavior we may not expect, but is how Ruby to_i operates
    it { is_expected.to run.with_params('12q').and_return(12) }
    it { is_expected.to run.with_params('q12').and_return(0) }
    it { is_expected.to run.with_params('-q12').and_return(0) }
    it { is_expected.to run.with_params('oops').and_return(0) }
    it { is_expected.to run.with_params('-1q12').and_return(-1) }
    it { is_expected.to run.with_params(nil).and_return(0) }
  end

  context 'should fail when conversion is not possible' do
   it { is_expected.to run.with_params([1, 2]).and_raise_error(/cannot be converted to an Integer/) }
   it { is_expected.to run.with_params({1 =>  2}).and_raise_error(/cannot be converted to an Integer/) }
  end
end
