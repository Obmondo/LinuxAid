require 'spec_helper'

describe 'cassandra::schema::index' do
  context 'Create a basic index' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        keys: 'lname',
        keyspace: 'mykeyspace',
        table: 'users',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_cassandra__schema__index('user_index')
      read_command = '/usr/bin/cqlsh   -e "DESC INDEX mykeyspace.user_index" localhost 9042'
      exec_command = '/usr/bin/cqlsh   -e "CREATE INDEX IF NOT EXISTS user_index ON mykeyspace.users (lname)" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a basic index with SCL' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        keys: 'lname',
        keyspace: 'mykeyspace',
        table: 'users',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_cassandra__schema__index('user_index')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC INDEX mykeyspace.user_index\" localhost 9042"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE INDEX IF NOT EXISTS user_index ON mykeyspace.users (lname)\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a custom index.' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        class_name: 'path.to.the.IndexClass',
        keys: 'email',
        keyspace: 'Excelsior',
        table: 'users',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/cqlsh   -e "DESC INDEX Excelsior.user_index" localhost 9042'
      exec_command = '/usr/bin/cqlsh   -e "CREATE CUSTOM INDEX IF NOT EXISTS user_index ON Excelsior.users (email) USING \'path.to.the.IndexClass\'" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a custom index with SCL.' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        class_name: 'path.to.the.IndexClass',
        keys: 'email',
        keyspace: 'Excelsior',
        table: 'users',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC INDEX Excelsior.user_index\" localhost 9042"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE CUSTOM INDEX IF NOT EXISTS user_index ON Excelsior.users (email) USING \'path.to.the.IndexClass\'\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a custom index with options.' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        class_name: 'path.to.the.IndexClass',
        keys: 'email',
        keyspace: 'Excelsior',
        options: "{'storage': '/mnt/ssd/indexes/'}",
        table: 'users',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/cqlsh   -e "DESC INDEX Excelsior.user_index" localhost 9042'
      exec_command =  '/usr/bin/cqlsh   -e "CREATE CUSTOM INDEX IF NOT EXISTS user_index ON '
      exec_command += 'Excelsior.users (email) USING \'path.to.the.IndexClass\' WITH OPTIONS = {'
      exec_command += '\'storage\': \'/mnt/ssd/indexes/\'}" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a custom index with options with SCL.' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        class_name: 'path.to.the.IndexClass',
        keys: 'email',
        keyspace: 'Excelsior',
        options: "{'storage': '/mnt/ssd/indexes/'}",
        table: 'users',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC INDEX Excelsior.user_index\" localhost 9042"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE CUSTOM INDEX IF NOT EXISTS user_index ON '
      exec_command += 'Excelsior.users (email) USING \'path.to.the.IndexClass\' WITH OPTIONS = {'
      exec_command += '\'storage\': \'/mnt/ssd/indexes/\'}\" localhost 9042"'
      is_expected.to contain_exec(exec_command).
        only_with(unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop Index' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        ensure: 'absent',
        keys: 'lname',
        keyspace: 'Excelsior',
        table: 'users',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/cqlsh   -e "DESC INDEX Excelsior.user_index" localhost 9042'
      exec_command = '/usr/bin/cqlsh   -e "DROP INDEX Excelsior.user_index" localhost 9042'
      is_expected.to contain_exec(exec_command).
        only_with(onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop Index with SCL' do
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

    let(:title) { 'user_index' }

    let(:params) do
      {
        ensure: 'absent',
        keys: 'lname',
        keyspace: 'Excelsior',
        table: 'users',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to compile
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DESC INDEX Excelsior.user_index\" localhost 9042"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP INDEX Excelsior.user_index\" localhost 9042"'
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
