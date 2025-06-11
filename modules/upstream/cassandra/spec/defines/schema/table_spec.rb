require 'spec_helper'

describe 'cassandra::schema::table' do
  context 'Create Table' do
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

    let(:title) { 'users' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        keyspace: 'Excelsior',
        columns:
          {
            'userid' => 'text',
            'username' => 'FROZEN<fullname>',
            'emails' => 'set<text>',
            'top_scores' => 'list<int>',
            'todo' => 'map<timestamp, text>',
            'COLLECTION-TYPE' => 'tuple<int, text,text>',
            'PRIMARY KEY' => '(userid)'
          },
        options:
          [
            'COMPACT STORAGE',
            'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
          ]
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_cassandra__schema__table('users')
      read_command =  '/usr/bin/cqlsh   -e "DESC TABLE Excelsior.users" localhost 9042'
      exec_command =  '/usr/bin/cqlsh   -e "CREATE TABLE IF NOT EXISTS Excelsior.users '
      exec_command += '(userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, '
      exec_command += 'todo map<timestamp, text>, tuple<int, text,text>, PRIMARY KEY (userid)) '
      exec_command += 'WITH COMPACT STORAGE AND ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\'" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create Table with SCL' do
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

    let(:title) { 'users' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        keyspace: 'Excelsior',
        columns:
          {
            'userid' => 'text',
            'username' => 'FROZEN<fullname>',
            'emails' => 'set<text>',
            'top_scores' => 'list<int>',
            'todo' => 'map<timestamp, text>',
            'COLLECTION-TYPE' => 'tuple<int, text,text>',
            'PRIMARY KEY' => '(userid)'
          },
        options:
          [
            'COMPACT STORAGE',
            'ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\''
          ]
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_cassandra__schema__table('users')
      read_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC TABLE Excelsior.users\" localhost 9042"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE TABLE IF NOT EXISTS Excelsior.users '
      exec_command += '(userid text, username FROZEN<fullname>, emails set<text>, top_scores list<int>, '
      exec_command += 'todo map<timestamp, text>, tuple<int, text,text>, PRIMARY KEY (userid)) '
      exec_command += 'WITH COMPACT STORAGE AND ID=\'5a1c395e-b41f-11e5-9f22-ba0be0483c18\'\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop Table' do
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

    let(:title) { 'users' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        keyspace: 'Excelsior',
        ensure: 'absent'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/cqlsh   -e "DESC TABLE Excelsior.users" localhost 9042'
      exec_command = '/usr/bin/cqlsh   -e "DROP TABLE IF EXISTS Excelsior.users" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop Table with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
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

    let(:title) { 'users' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        keyspace: 'Excelsior',
        ensure: 'absent'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC TABLE Excelsior.users\" localhost 9042"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP TABLE IF EXISTS Excelsior.users\" localhost 9042"'
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
