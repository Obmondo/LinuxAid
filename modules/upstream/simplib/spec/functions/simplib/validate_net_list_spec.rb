require 'spec_helper'

describe 'simplib::validate_net_list' do
  context 'IPv4' do
    describe 'valid IPv4 string' do
      it 'validates address-only' do
       is_expected.to run.with_params('1.2.3.4')
      end

      it 'validates address plus port' do
        is_expected.to run.with_params('1.2.3.4:5678')
      end

      it 'validates CIDR with numeric network mask' do
        is_expected.to run.with_params('1.2.0.0/16')
      end

      it 'validates CIDR with quad-dotted network mask' do
        is_expected.to run.with_params('1.2.0.0/255.255.0.0')
      end
    end

    describe 'invalid IPv4 string' do
      it 'rejects invalid octet' do
        is_expected.to run.with_params('1.2.3.256').and_raise_error(/'1.2.3.256' is not a valid network/)
      end

      it 'rejects CIDR missing network mask' do
        pending "IPAddr allows empty network mask '1.2.3.4/'"
        is_expected.to run.with_params('1.2.3.4/').and_raise_error(RuntimeError)
      end

      it 'rejects CIDR with invalid numeric network mask' do
        is_expected.to run.with_params('1.2.3.4/33').and_raise_error(/'1.2.3.4\/33' is not a valid network/)
      end

      it 'rejects CIDR with invalid quad-dotted network mask' do
        is_expected.to run.with_params('1.2.3.4/256.255.0.0').and_raise_error(/'1.2.3.4\/256.255.0.0' is not a valid network/)
      end

      it 'rejects invalid port' do
        is_expected.to run.with_params('1.2.3.4:66000').and_raise_error(/'66000' is not a valid port/)
      end
    end
  end

  context 'IPv6' do
    describe 'valid IPv6 string' do
      it 'validates fully-specified, address-only' do
        is_expected.to run.with_params('2001:0db8:85a3:0000:0000:8a2e:0370:7334')
      end

      it 'validates abbreviated, address-only' do
        is_expected.to run.with_params('2001:0db8:85a3::0000:8a2e:0370:7334')
      end

      it 'validates address plus port' do
        is_expected.to run.with_params('[2001:db8:a::]:64')
      end

      it 'validates CIDR with numeric network mask' do
        is_expected.to run.with_params('2001:db8:a::/64')
      end

      it 'validates CIDR with hex network mask' do
        is_expected.to run.with_params('2001:0db8:030a:4000:0360:ff00:0042:0000/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0000')
      end
    end

    describe 'invalid IPv6 string' do
      it 'rejects invalid octet' do
        is_expected.to run.with_params('20011:db8:a::').and_raise_error(/'20011:db8:a::' is not a valid network/)
      end

      it 'rejects CIDR missing network mask' do
        pending "IPAddr allows empty network mask '2001:db8:a::/'"
        is_expected.to run.with_params('2001:db8:a::/').and_raise_error(RuntimeError)
      end

      it 'rejects CIDR with invalid numeric network mask' do
        is_expected.to run.with_params('20011:db8:a::/129').and_raise_error(/'20011:db8:a::\/129' is not a valid network/)
      end

      it 'rejects CIDR with invalid hex network mask' do
        is_expected.to run.with_params('2001:0db8:030a:4000:0360:ff00:0042:0000/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFFFFF:0000').and_raise_error(/'2001:0db8:030a:4000:0360:ff00:0042:0000\/FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFFFFF:0000' is not a valid network/)
      end

      it 'rejects invalid port' do
        is_expected.to run.with_params('[2001:db8:a::]:66000').and_raise_error(/'66000' is not a valid port/)
      end
    end
  end

  context 'hostname' do
    describe 'valid hostname string' do
      it 'validates hostname without domain' do
        is_expected.to run.with_params('myhost')
      end

      it 'validates hostname with domain' do
        is_expected.to run.with_params('myhost.test.local')
      end

      it 'validates hostname with domain and port' do
        is_expected.to run.with_params('myhost.test.local:8080')
      end

      it 'validates AWS instance hostname ' do
        is_expected.to run.with_params('myhost-test.local')
      end
    end

    describe 'invalid hostname string' do
      it 'rejects invalid hostname' do
        is_expected.to run.with_params('my$bad$hostname').and_raise_error(/'my\$bad\$hostname' is not a valid network/)
      end

      it 'rejects invalid port' do
        is_expected.to run.with_params('myhostname:-10').and_raise_error(/'-10' is not a valid port/)
      end
    end
  end

  context 'regex match' do
    describe 'valid match for pattern that cannot be a hostname' do
      it { is_expected.to run.with_params('%any', '%any') }
      it { is_expected.to run.with_params('%any', '^(%any|%none)$') }
      it { is_expected.to run.with_params('case/requiring/escapes', '^case\/requiring\/escapes$') }
      it { is_expected.to run.with_params('*', '\*') }
      it { is_expected.to run.with_params('*', '*') }
    end
  end

  context 'array' do
    describe 'valid array' do
      it 'validates when all elements are valid' do
        is_expected.to run.with_params(['1.2.3.4:5678', '[2001:db8:a::]:64'], 'myhost')
        is_expected.to run.with_params(['1.2.3.4:10', '[2001:db8:a::]:64', 'my?host'], '^my\?host$')
      end
    end

    describe 'invalid array' do
     it 'rejects when any element is invalid' do
        is_expected.to run.with_params(['1.2.3.4:-10', '[2001:db8:a::]:64', 'myhost']).and_raise_error(/is not a valid/)
        is_expected.to run.with_params(['1.2.3.4:10', '[2001:db8:a ::]:64', 'myhost']).and_raise_error(/is not a valid/)
        is_expected.to run.with_params(['1.2.3.4:10', '[2001:db8:a::]:64', 'my?host']).and_raise_error(/is not a valid/)
        is_expected.to run.with_params(['1.2.3.4:10', '[2001:db8:a::]:64', 'my?host '], '^my\?host$').and_raise_error(/is not a valid/)
      end
    end
  end
end
