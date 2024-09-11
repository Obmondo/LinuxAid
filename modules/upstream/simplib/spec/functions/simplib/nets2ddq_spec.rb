#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::nets2ddq' do
  context 'should return converted values when conversion is possible' do
    it 'converts an Array of networks' do
      input = [
        '10.0.1.0/24',
        '10.0.2.0/255.255.255.0',
        '10.0.3.25',
        'myhost',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      ]
      expected_output = [
        '10.0.1.0/255.255.255.0',
        '10.0.2.0/255.255.255.0',
        '10.0.3.25',
        'myhost',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      ]

      is_expected.to run.with_params(input).and_return(expected_output)
    end

    it 'converts a String of space-separated networks' do
      input = '10.0.1.0/24 10.0.2.0/255.255.255.0   10.0.3.25 myhost 2001:0db8:85a3:0000:0000:8a2e:0370:7334 2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      expected_output = [
        '10.0.1.0/255.255.255.0',
        '10.0.2.0/255.255.255.0',
        '10.0.3.25',
        'myhost',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)
    end

    it 'converts a String of comma-separated networks' do
      input = '10.0.1.0/24,,10.0.2.0/255.255.255.0,10.0.3.25,myhost,2001:0db8:85a3:0000:0000:8a2e:0370:7334,2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      expected_output = [
        '10.0.1.0/255.255.255.0',
        '10.0.2.0/255.255.255.0',
        '10.0.3.25',
        'myhost',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)
    end

    it 'converts a String of semi-colon-separated networks' do
      input = ';10.0.1.0/24;10.0.2.0/255.255.255.0;10.0.3.25;myhost;2001:0db8:85a3:0000:0000:8a2e:0370:7334;2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      expected_output = [
        '10.0.1.0/255.255.255.0',
        '10.0.2.0/255.255.255.0',
        '10.0.3.25',
        'myhost',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
      ]
      is_expected.to run.with_params(input).and_return(expected_output)
    end

    it 'returns an empty Array when no networks specified' do
      input_string = '  '
      expected_output = []
      is_expected.to run.with_params(input_string).and_return(expected_output)

      input_array = []
      expected_output = []
      is_expected.to run.with_params(input_array).and_return(expected_output)
    end

  end

  context 'should fail when conversion is not possible' do
   it {
     input = ['myhost', '-bad.']
     is_expected.to run.with_params(input).and_raise_error(/'-bad.' is not a valid network./)
   }
  end
end
