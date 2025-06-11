require 'spec_helper'

describe 'cassandra::schema::keyspace' do
  context 'Set ensure to present (SimpleStrategy)' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'present',
        replication_map:
          {
            'keyspace_class'     => 'SimpleStrategy',
            'replication_factor' => 3
          },
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_class('cassandra::schema')
      read_command =  '/usr/bin/cqlsh   -e "DESC KEYSPACE foobar" localhost 9042'
      exec_command =  '/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = '
      exec_command += '{ \'class\' : \'SimpleStrategy\', \'replication_factor\' : 3 } '
      exec_command += 'AND DURABLE_WRITES = true" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Set ensure to present (SimpleStrategy) with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'present',
        replication_map:
          {
            'keyspace_class'     => 'SimpleStrategy',
            'replication_factor' => 3
          },
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to compile
      read_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC KEYSPACE foobar\" localhost 9042"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = '
      exec_command += '{ \'class\' : \'SimpleStrategy\', \'replication_factor\' : 3 } '
      exec_command += 'AND DURABLE_WRITES = true\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Set ensure to present (NetworkTopologyStrategy)' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'present',
        replication_map:
          {
            'keyspace_class' => 'NetworkTopologyStrategy',
            'dc1'            => '3',
            'dc2'            => '2'
          },
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to contain_cassandra__schema__keyspace('foobar')
      read_command =  '/usr/bin/cqlsh   -e "DESC KEYSPACE foobar" localhost 9042'
      exec_command =  '/usr/bin/cqlsh   -e "CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = '
      exec_command += '{ \'class\' : \'NetworkTopologyStrategy\', \'dc1\': 3, \'dc2\': 2 } '
      exec_command += 'AND DURABLE_WRITES = true" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Set ensure to present (NetworkTopologyStrategy) with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'present',
        replication_map:
          {
            'keyspace_class' => 'NetworkTopologyStrategy',
            'dc1'            => '3',
            'dc2'            => '2'
          },
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to contain_cassandra__schema__keyspace('foobar')
      read_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC KEYSPACE foobar\" localhost 9042"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE KEYSPACE IF NOT EXISTS foobar WITH REPLICATION = '
      exec_command += '{ \'class\' : \'NetworkTopologyStrategy\', \'dc1\': 3, \'dc2\': 2 } '
      exec_command += 'AND DURABLE_WRITES = true\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Set ensure to absent' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }
    let(:params) do
      {
        ensure: 'absent',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/cqlsh   -e "DESC KEYSPACE foobar" localhost 9042'
      exec_command = '/usr/bin/cqlsh   -e "DROP KEYSPACE foobar" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Set ensure to absent with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }
    let(:params) do
      {
        ensure: 'absent',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC KEYSPACE foobar\" localhost 9042"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP KEYSPACE foobar\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Set ensure to latest' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let(:title) { 'foobar' }

    let(:params) do
      {
        ensure: 'latest'
      }
    end

    it { is_expected.to raise_error(Puppet::Error) }
  end
end
