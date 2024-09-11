require 'spec_helper'

describe 'simplib::validate_uri_list' do

  context 'Valid URIs with hostnames' do
    it { is_expected.to run.with_params('fuu.bar.baz') }
    it { is_expected.to run.with_params(['fuu.bar.baz', 'my.example.net:900']) }
    it {
      is_expected.to run.with_params([
        'http://some.domain.net',
        'https://some.domain.net',
        'ldaps://localhost.my.domain:8989'
      ])
    }

    # unexpected behavior: really need to specify scheme_list or fat-finger mistakes
    # will not be caught
    it { is_expected.to run.with_params('htps://1.2.3.4') }
  end

  context 'Valid URIs with IPv4' do
    it { is_expected.to run.with_params('rsync://127.0.0.1:1234') }
    it {
      is_expected.to run.with_params(
        ['ldap://1.2.3.4', 'ldaps://1.2.3.4'],
        ['ldap', 'ldaps']
      )
    }
  end

  context 'Valid URIs with IPv6' do
    it {
      is_expected.to run.with_params(
        [
          'ldap://[2001:db8:1f70::999:de8:7648:001]:100',
          'ldaps://[2001:db8:1f70::999:de8:7648:002]'
        ],
        ['ldap', 'ldaps']
      )
    }
  end

  context 'Invalid URIs' do
    it { is_expected.to run.with_params('').and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params([]).and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params('ldap://1.2.3.4:567:oops').and_raise_error(/is not a valid URI/) }
    it {
      is_expected.to run.with_params(
        [ 'ldap://1.2.3.4', 'ldaps://1.2.3.4' ], [ 'http', 'https' ]
      ).and_raise_error(/'ldap' must be one of \["http", "https"\]/)
    }

    it {
      is_expected.to run.with_params('ldap://[2001:db8:1f70::999:de8:7648:]').and_raise_error(/is not a valid URI/)
    }

    it {
      is_expected.to run.with_params(
          [ 'http://1.2.3.4', 'ldaps://[2001:db8:1f70::999:de8:7648:002]' ], [ 'http' ]
      ).and_raise_error(/'ldaps' must be one of \["http"\]/)
    }
  end
end
