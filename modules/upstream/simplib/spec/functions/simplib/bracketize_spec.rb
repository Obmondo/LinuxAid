#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::bracketize' do
  context 'should return converted values when conversion is possible' do
    it 'converts an Array of networks' do
      input = [
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24'
      ]
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)

      input = '2001:0db8:85a3:0000:0000:8a2e:0370:7334 2001:0db8:85a3:0000:0000:8a2e:0370:7334/24'
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)

      input = '2001:0db8:85a3:0000:0000:8a2e:0370:7334, 2001:0db8:85a3:0000:0000:8a2e:0370:7334/24'
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)

      input = '2001:0db8:85a3:0000:0000:8a2e:0370:7334; 2001:0db8:85a3:0000:0000:8a2e:0370:7334/24'
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)

      input = '2001:0db8:85a3:0000:0000:8a2e:0370:7334; 2001:0db8:85a3:0000:0000:8a2e:0370:7334/24 3456:0db8:85a3:0000:0000:8a2e:0370:7334, 1274:0db8:85a3:0000:0000:8a2e:0370:7334'
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24',
        '[3456:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[1274:0db8:85a3:0000:0000:8a2e:0370:7334]'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)
    end

    it 'returns same input if not an ipv6' do
      input_string = 'correct'
      expected_output = 'correct'
      is_expected.to run.with_params(input_string).and_return(expected_output)

      input_array = []
      expected_output = []
      is_expected.to run.with_params(input_array).and_return(expected_output)
    end

    it 'returns same input if ipv6 is already in brackets' do
      input_string = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      is_expected.to run.with_params(input_string).and_return(expected_output)

      input_string = '[2001:0db8:85a3:0000:0000:8a2e:0370:7334] [2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      expected_output = [
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24'
      ]
      is_expected.to run.with_params(input_string).and_return(expected_output)
    end

    it 'returns same input if not an ipv6, but still converts if intermingled' do
      input_string = 'still correct 2001:0db8:85a3:0000:0000:8a2e:0370:7334 127.0.0.1'
      expected_output = [
        'still',
        'correct',
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
        '127.0.0.1'
      ]
      is_expected.to run.with_params(input_string).and_return(expected_output)
    end
  end
end
