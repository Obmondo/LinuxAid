#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::ip::family_hash' do
  it 'converts an Array of addresses' do
    input = [
      '1.2.3.4/24',
      '2.3.4.5',
      '3.4.5.0/255.255.255.0',
      '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
      '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
      '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24'
    ]

    output ={
      'ipv4' => {
        '1.2.3.4/24' => {
          'address' => '1.2.3.0',
          'netmask' => {
            'ddq'  => '255.255.255.0',
            'cidr' => 24
          }
        },
        '2.3.4.5' => {
          'address' => '2.3.4.5',
          'netmask' => {
            'ddq'  => '255.255.255.255',
            'cidr' => 32
          }
        },
        '3.4.5.0/255.255.255.0' => {
          'address' => '3.4.5.0',
          'netmask' => {
            'ddq'  => '255.255.255.0',
            'cidr' => 24
          }
        }
      },
      'ipv6' => {
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334' => {
          'address' => '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          'netmask' => {
            'ddq'  => nil,
            'cidr' => 128
          }
        },
        '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]' => {
          'address' => '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          'netmask' => {
            'ddq'  => nil,
            'cidr' => 128
          }
        },
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24' => {
          'address' => '2001:d00::',
          'netmask' => {
            'ddq'  => nil,
            'cidr' => 24
          }
        }
      }
    }

    is_expected.to run.with_params(input).and_return(output)
  end

  it 'converts a single IPv4 address' do
    input = '1.2.3.4/24'

    output = {
      'ipv4' => {
        '1.2.3.4/24' => {
          'address' => '1.2.3.0',
          'netmask' => {
            'ddq'  => '255.255.255.0',
            'cidr' => 24
          }
        }
      }
    }

    is_expected.to run.with_params(input).and_return(output)
  end

  it 'converts a single IPv6 address' do
    input = '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24'

    output = {
      'ipv6' => {
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24' => {
          'address' => '2001:d00::',
          'netmask' => {
            'ddq'  => nil,
            'cidr' => 24
          }
        }
      }
    }

    is_expected.to run.with_params(input).and_return(output)
  end

  it 'collects unknown entries' do
    input = [
      '1.2.3.4',
      '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24',
      'bob.the.builder'
    ]

    output = {
      'ipv4' => {
        '1.2.3.4' => {
          'address' => '1.2.3.4',
          'netmask' => {
            'ddq'  => '255.255.255.255',
            'cidr' => 32
          }
        },
      },
      'ipv6' => {
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24' => {
          'address' => '2001:d00::',
          'netmask' => {
            'ddq'  => nil,
            'cidr' => 24
          }
        }
      },
      'unknown' => {
        'bob.the.builder' => {
          'address' => 'bob.the.builder',
          'netmask' => {
            'ddq' => nil,
            'cidr' => nil
          }
        }
      }
    }

    is_expected.to run.with_params(input).and_return(output)
  end
end
