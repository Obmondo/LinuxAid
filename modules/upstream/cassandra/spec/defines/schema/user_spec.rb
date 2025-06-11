require 'spec_helper'

describe 'cassandra::schema::user' do
  context 'Create a supper user on cassandrarelease undef' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: nil,
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*akers |\''
      exec_command =  '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER" localhost 9042'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a supper user on cassandrarelease undef with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: nil,
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*akers |\'"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE USER IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER\" localhost 9042"'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a supper user in cassandrarelease < 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.1',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*akers |\''
      exec_command =  '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER" localhost 9042'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a supper user in cassandrarelease < 2.2 with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.1',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*akers |\'"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE USER IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER\" localhost 9042"'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a user in cassandrarelease < 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.1',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'Niner2'
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*akers |\''
      exec_command =  '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD \'Niner2\' NOSUPERUSER" localhost 9042'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a user in cassandrarelease < 2.2 with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.1',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'Niner2'
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*akers |\'"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE USER IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD \'Niner2\' NOSUPERUSER\" localhost 9042"'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a supper user with login in cassandrarelease > 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*akers |\''
      exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD = \'Niner2\' AND SUPERUSER = true AND LOGIN = true" localhost 9042'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a supper user with login in cassandrarelease > 2.2 with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'Niner2',
        superuser: true
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('akers').with_ensure('present')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep \'\s*akers |\'"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE ROLE IF NOT EXISTS akers'
      exec_command += ' WITH PASSWORD = \'Niner2\' AND SUPERUSER = true AND LOGIN = true\" localhost 9042"'
      is_expected.to contain_exec('Create user (akers)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a user without login in cassandrarelease > 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9',
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

    let(:title) { 'bob' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'kaZe89a',
        login: false
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('bob').with_ensure('present')
      read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*bob |\''
      exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS bob'
      exec_command += ' WITH PASSWORD = \'kaZe89a\'" localhost 9042'
      is_expected.to contain_exec('Create user (bob)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Create a user without login in cassandrarelease > 2.2 with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9',
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

    let(:title) { 'bob' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'kaZe89a',
        login: false
      }
    end

    it do
      is_expected.to contain_cassandra__schema__user('bob').with_ensure('present')
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep \'\s*bob |\'"'
      exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE ROLE IF NOT EXISTS bob'
      exec_command += ' WITH PASSWORD = \'kaZe89a\'\" localhost 9042"'
      is_expected.to contain_exec('Create user (bob)').
        only_with(command: exec_command,
                  unless: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop a user in cassandrarelease > 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'Niner2',
        ensure: 'absent'
      }
    end

    it do
      read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*akers |\''
      exec_command = '/usr/bin/cqlsh   -e "DROP ROLE akers" localhost 9042'
      is_expected.to contain_exec('Delete user (akers)').
        only_with(command: exec_command,
                  onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop a user in cassandrarelease > 2.2 with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '3.0.9',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'Niner2',
        ensure: 'absent'
      }
    end

    it do
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep \'\s*akers |\'"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP ROLE akers\" localhost 9042"'
      is_expected.to contain_exec('Delete user (akers)').
        only_with(command: exec_command,
                  onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop a user in cassandrarelease < 2.2' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.2',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: false,
        scl_name: 'nodefault',
        password: 'Niner2',
        ensure: 'absent'
      }
    end

    it do
      read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*akers |\''
      exec_command = '/usr/bin/cqlsh   -e "DROP USER akers" localhost 9042'
      is_expected.to contain_exec('Delete user (akers)').
        only_with(command: exec_command,
                  onlyif: read_command,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'Drop a user in cassandrarelease < 2.2 with SCL' do
    let :facts do
      {
        operatingsystemmajrelease: 7,
        osfamily: 'RedHat',
        cassandrarelease: '2.0.2',
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

    let(:title) { 'akers' }

    let(:params) do
      {
        use_scl: true,
        scl_name: 'testscl',
        password: 'Niner2',
        ensure: 'absent'
      }
    end

    it do
      read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*akers |\'"'
      exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP USER akers\" localhost 9042"'
      is_expected.to contain_exec('Delete user (akers)').
        only_with(command: exec_command,
                  onlyif: read_command,
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
