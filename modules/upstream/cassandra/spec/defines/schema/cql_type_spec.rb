require 'spec_helper'

describe 'cassandra::schema::cql_type' do
  context 'CQL TYPE (fullname)' do
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

    let(:title) { 'fullname' }

    let(:params) do
      {
        'keyspace' => 'Excelsior',
        fields:
          {
            'firstname' => 'text',
            'lastname'  => 'text'
          },
        'use_scl'  => false,
        'scl_name' => 'nodefault'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_class('cassandra::schema')
      is_expected.to contain_cassandra__schema__cql_type('fullname')
      read_command = '/usr/bin/cqlsh   -e "DESC TYPE Excelsior.fullname" localhost 9042'
      exec_command =  '/usr/bin/cqlsh   -e "CREATE TYPE IF NOT EXISTS Excelsior.fullname '
      exec_command += '(firstname text, lastname text)" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'CQL TYPE (fullname) with SCL' do
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

    let(:title) { 'fullname' }

    let(:params) do
      {
        'keyspace' => 'Excelsior',
        fields:
          {
            'firstname' => 'text',
            'lastname'  => 'text'
          },
        'use_scl'  => true,
        'scl_name' => 'testscl'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_class('cassandra::schema')
      is_expected.to contain_cassandra__schema__cql_type('fullname')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC TYPE Excelsior.fullname\" localhost 9042"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE TYPE IF NOT EXISTS Excelsior.fullname '
      exec_command += '(firstname text, lastname text)\" localhost 9042"'
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

    let(:title) { 'address' }
    let(:params) do
      {
        'ensure'   => 'absent',
        'keyspace' => 'Excalibur',
        'use_scl'  => false,
        'scl_name' => 'nodefault'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_cassandra__schema__cql_type('address')
      read_command = '/usr/bin/cqlsh   -e "DESC TYPE Excalibur.address" localhost 9042'
      exec_command = '/usr/bin/cqlsh   -e "DROP type Excalibur.address" localhost 9042'
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

    let(:title) { 'address' }
    let(:params) do
      {
        'ensure'   => 'absent',
        'keyspace' => 'Excalibur',
        'use_scl'  => true,
        'scl_name' => 'testscl'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_cassandra__schema__cql_type('address')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC TYPE Excalibur.address\" localhost 9042"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP type Excalibur.address\" localhost 9042"'
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
