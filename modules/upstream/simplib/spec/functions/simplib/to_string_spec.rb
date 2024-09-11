#!/usr/bin/env ruby -S rspec
require 'spec_helper'

class ClassWithoutTo_s
  undef_method :to_s
end

describe 'simplib::to_string' do
  context 'should return converted value when conversion is possible' do
    it { is_expected.to run.with_params('12').and_return('12') }
    it { is_expected.to run.with_params(12).and_return('12') }
    it { is_expected.to run.with_params(nil).and_return('') }

    # Perhaps unexpected behavior? If we don't want this, we need to
    # change the required_param type in the :to_string dispatch
    it { is_expected.to run.with_params( [34, 56] ).and_return('[34, 56]') }
    it { is_expected.to run.with_params( {'tag'=> 'value'} ).and_return('{"tag"=>"value"}') }
  end

  context 'should fail when conversion is not possible' do
   odd_var = ClassWithoutTo_s.new
   it { is_expected.to run.with_params(odd_var).and_raise_error(/cannot be converted to a String/) }
  end
end
