require 'spec_helper'
describe 'cassandra::datastax_repo' do
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

    it do
      is_expected.to have_resource_count(1)

      is_expected.to contain_class('cassandra::datastax_repo').only_with(
        'descr'   => 'DataStax Repo for Apache Cassandra',
        'key_id'  => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        'key_url' => 'http://debian.datastax.com/debian/repo_key',
        'release' => 'stable'
      )

      is_expected.to contain_yumrepo('datastax').with(
        ensure: 'present',
        descr: 'DataStax Repo for Apache Cassandra',
        baseurl: 'http://rpm.datastax.com/community',
        enabled: 1,
        gpgcheck: 0
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
          'name' => 'Debian',
          'family' => 'Debian',
          'release' => {
            'major' => '9',
            'minor' => '9',
            'full'  => '9.9'
          }
        }
      }
    end

    it do
      is_expected.to contain_class('apt')
      is_expected.to contain_class('apt::update')

      is_expected.to contain_apt__key('datastaxkey').with(
        id: '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        source: 'http://debian.datastax.com/debian/repo_key'
      )

      is_expected.to contain_apt__source('datastax').with(
        location: 'http://debian.datastax.com/community',
        comment: 'DataStax Repo for Apache Cassandra',
        release: 'stable',
        include: { 'src' => false }
      ).that_notifies('Exec[update-cassandra-repos]')

      is_expected.to contain_exec('update-cassandra-repos').with(
        refreshonly: true,
        command: '/bin/true'
      )
    end
  end
end
