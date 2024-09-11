require 'spec_helper'

describe 'simplib::nets2cidr' do
  context 'with valid string input' do
    context 'single hostname/network/address' do
      it 'converts IPv4 network to CIDR format' do
        is_expected.to run.with_params('1.2.0.0/255.255.0.0').and_return(['1.2.0.0/16'])
      end

      it 'converts IPv6 network to CIDR format' do
        input = '2001:db8:30a:4000:360:ff00:42:0/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0000'
        expected_output = [ '2001:db8:30a:4000:360:ff00:42:0/112' ]
        is_expected.to run.with_params(input).and_return(expected_output)
      end

      it 'passes through a IPv4 network in CIDR format' do
         is_expected.to run.with_params('1.2.3.0/24').and_return(['1.2.3.0/24'])
      end

      it 'passes through a IPv4 address' do
         is_expected.to run.with_params('1.2.3.4').and_return(['1.2.3.4'])
      end

      it 'passes through a IPv6 network in CIDR format' do
        input = '2001:db8:85a3::8a2e:370:0/112'
        expected_output = [ input ]
        is_expected.to run.with_params(input).and_return(expected_output)
      end

      it 'passes through a IPv6 address' do
        input = '2001:db8:85a3::8a2e:370:a754'
        expected_output = [ input ]
        is_expected.to run.with_params(input).and_return(expected_output)
      end

      it 'passes through a hostname' do
         is_expected.to run.with_params('myhost.test.local').and_return(['myhost.test.local'])
      end
    end

    context 'multiple hostnames/networks/addresses' do
      let(:expected_output) do
        [
          'myhost-test.local',
          '1.2.3.0/24',
          '2001:db8:85a3::8a2e:370:0/112'
        ]
      end

      it 'converts addresses/hostnames separated by whitespace' do
        input = " myhost-test.local   1.2.3.0/255.255.255.0\t2001:db8:85a3::8a2e:370:0/112 "
        is_expected.to run.with_params(input).and_return(expected_output)
      end

      it 'converts addresses/hostnames separated by a comma' do
        input = ",myhost-test.local,,1.2.3.0/255.255.255.0\t2001:db8:85a3::8a2e:370:0/112,"
        is_expected.to run.with_params(input).and_return(expected_output)
      end

      it 'converts addresses/hostnames separated by a semi-colon' do
        input = ";myhost-test.local;;1.2.3.0/255.255.255.0\t2001:db8:85a3::8a2e:370:0/112;"
        is_expected.to run.with_params(input).and_return(expected_output)
      end
    end
  end

  context 'with valid Array input' do
    it 'converts each hostname/network/address' do
      input = [
        '1.2.0.0/255.255.0.0',
        '2001:db8:30a:4000:360:ff00:42:0/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0000',
        '1.2.3.0/24',
        '1.2.3.4',
        '2001:db8:85a3::8a2e:370:0/112',
        '2001:db8:85a3::8a2e:370:a754',
        'myhost.test.local'
      ]

      expected_output = [
        '1.2.0.0/16',
        '2001:db8:30a:4000:360:ff00:42:0/112',
        '1.2.3.0/24',
        '1.2.3.4',
        '2001:db8:85a3::8a2e:370:0/112',
        '2001:db8:85a3::8a2e:370:a754',
        'myhost.test.local'
      ]
        is_expected.to run.with_params(input).and_return(expected_output)
    end
  end

  context 'with invalid input' do
    [ '1.2.3.4/33',          # bad network mask
      '1.2.3.4/256.255.0.0', # bad network mask
      '20011:db8:a::',       # bad IPv6
      '20011:db8:a::/129',   # bad network mask
      '2001:0db8:030a:4000:0360:ff00:0042:0000/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFFFFF:0000', # bad network mask
      'my$bad$hostname'      # bad hostname
    ].each do |invalid_entry|
      it 'fails with invalid input' do
        is_expected.to run.with_params(invalid_entry).and_raise_error(/ is not a valid network/)
      end
    end

    it 'fails with invalid Array input' do
      is_expected.to run.with_params(['myhost.test.local', '1.2.3.4/33', '4.5.6.7']).and_raise_error(
        /'1.2.3.4\/33' is not a valid network/
      )
    end
  end

end
