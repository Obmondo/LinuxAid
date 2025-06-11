require 'spec_helper'
describe 'cassandra::apache_repo' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat',
        os: {
          'family'  => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let :params do
      {
        release: '311x'
      }
    end

    it do
      is_expected.to have_resource_count(1)

      is_expected.to contain_class('cassandra::apache_repo').only_with(
        'descr'   => 'Repo for Apache Cassandra',
        'key_id'  => 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        'key_url' => 'https://www.apache.org/dist/cassandra/KEYS',
        'release' => '311x'
      )

      is_expected.to contain_yumrepo('cassandra_apache').with(
        ensure: 'present',
        descr: 'Repo for Apache Cassandra',
        baseurl: 'http://www.apache.org/dist/cassandra/redhat/311x',
        enabled: 1,
        gpgcheck: 1,
        gpgkey: 'https://www.apache.org/dist/cassandra/KEYS'
      )
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Debian',
        lsbdistrelease: '9',
        os: {
          'family'  => 'Debian',
          'name'    => 'Debian',
          'release' => {
            'full'  => '9.9',
            'major' => '9',
            'minor' => '9'
          }
        }
      }
    end

    it do
      is_expected.to contain_class('apt')
      is_expected.to contain_class('apt::update')

      is_expected.to contain_apt__key('apache.cassandra').with(
        id: 'A26E528B271F19B9E5D8E19EA278B781FE4B2BDA',
        source: 'https://www.apache.org/dist/cassandra/KEYS'
      )

      is_expected.to contain_apt__source('cassandra.sources').with(
        location: 'http://www.apache.org/dist/cassandra/debian',
        comment: 'Repo for Apache Cassandra',
        release: 'main',
        include: { 'src' => false }
      ).that_notifies('Exec[update-apache-cassandra-repo]')

      is_expected.to contain_exec('update-apache-cassandra-repo').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
