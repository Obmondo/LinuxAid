require 'spec_helper'

describe 'cassandra::schema::permission' do
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
        user_name: 'foobar'
      }
    end

    it { is_expected.to raise_error(Puppet::Error) }
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

  context 'spillman:SELECT:ALL' do
    let(:title) { 'spillman:SELECT:ALL' }
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

    let(:params) do
      {
        user_name: 'spillman',
        permission_name: 'SELECT',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('spillman:SELECT:ALL')
      read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON ALL KEYSPACES" '
      read_script += 'localhost 9042 | grep \' spillman | *spillman | .* SELECT$\''
      script_command = 'GRANT SELECT ON ALL KEYSPACES TO spillman'
      exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  unless: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'spillman:SELECT:ALL with SCL' do
    let(:title) { 'spillman:SELECT:ALL' }
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

    let(:params) do
      {
        user_name: 'spillman',
        permission_name: 'SELECT',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('spillman:SELECT:ALL')
      read_script =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ALL PERMISSIONS ON ALL KEYSPACES\" '
      read_script += 'localhost 9042 | grep \' spillman | *spillman | .* SELECT$\'"'
      script_command = 'GRANT SELECT ON ALL KEYSPACES TO spillman'
      exec_command = "/usr/bin/scl enable testscl \"/usr/bin/cqlsh   -e \\\"#{script_command}\\\" localhost 9042\""
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  unless: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'akers:modify:field' do
    let(:title) { 'akers:modify:field' }
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

    let(:params) do
      {
        user_name: 'akers',
        keyspace_name: 'field',
        permission_name: 'MODIFY',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('akers:modify:field')
      read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON KEYSPACE field" '
      read_script += 'localhost 9042 | grep \' akers | *akers | .* MODIFY$\''
      script_command = 'GRANT MODIFY ON KEYSPACE field TO akers'
      exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  unless: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'akers:modify:field with SCL' do
    let(:title) { 'akers:modify:field' }
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

    let(:params) do
      {
        user_name: 'akers',
        keyspace_name: 'field',
        permission_name: 'MODIFY',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('akers:modify:field')
      read_script =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ALL PERMISSIONS ON KEYSPACE field\" '
      read_script += 'localhost 9042 | grep \' akers | *akers | .* MODIFY$\'"'
      script_command = 'GRANT MODIFY ON KEYSPACE field TO akers'
      exec_command = "/usr/bin/scl enable testscl \"/usr/bin/cqlsh   -e \\\"#{script_command}\\\" localhost 9042\""
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  unless: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'boone:alter:forty9ers' do
    let(:title) { 'boone:alter:forty9ers' }
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

    let(:params) do
      {
        user_name: 'boone',
        keyspace_name: 'forty9ers',
        permission_name: 'ALTER',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('boone:alter:forty9ers')
      read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON KEYSPACE forty9ers" '
      read_script += 'localhost 9042 | grep \' boone | *boone | .* ALTER$\''
      script_command = 'GRANT ALTER ON KEYSPACE forty9ers TO boone'
      exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  unless: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'boone:alter:forty9ers with SCL' do
    let(:title) { 'boone:alter:forty9ers' }
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

    let(:params) do
      {
        user_name: 'boone',
        keyspace_name: 'forty9ers',
        permission_name: 'ALTER',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('boone:alter:forty9ers')
      read_script =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ALL PERMISSIONS ON KEYSPACE forty9ers\" '
      read_script += 'localhost 9042 | grep \' boone | *boone | .* ALTER$\'"'
      script_command = 'GRANT ALTER ON KEYSPACE forty9ers TO boone'
      exec_command = "/usr/bin/scl enable testscl \"/usr/bin/cqlsh   -e \\\"#{script_command}\\\" localhost 9042\""
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  unless: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'boone:ALL:ravens.plays' do
    let(:title) { 'boone:ALL:ravens.plays' }
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

    let(:params) do
      {
        user_name: 'boone',
        keyspace_name: 'ravens',
        table_name: 'plays',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to have_resource_count(18)
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays')
    end

    expected_values = %w[ALTER AUTHORIZE DROP MODIFY SELECT]
    expected_values.each do |val|
      it do
        is_expected.to contain_cassandra__schema__permission("boone:ALL:ravens.plays - #{val}").with(
          ensure: 'present',
          user_name: 'boone',
          keyspace_name: 'ravens',
          permission_name: val,
          table_name: 'plays'
        )
      end
      read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON TABLE ravens.plays" '
      read_script += "localhost 9042 | grep ' boone | *boone | .* #{val}$'"
      script_command = "GRANT #{val} ON TABLE ravens.plays TO boone"
      exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"
      it do
        is_expected.to contain_exec(script_command).
          only_with(command: exec_command,
                    unless: read_script,
                    require: 'Exec[::cassandra::schema connection test]')
      end
    end
  end

  context 'boone:ALL:ravens.plays with SCL' do
    let(:title) { 'boone:ALL:ravens.plays' }
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

    let(:params) do
      {
        user_name: 'boone',
        keyspace_name: 'ravens',
        table_name: 'plays',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to have_resource_count(18)
      is_expected.to contain_cassandra__schema__permission('boone:ALL:ravens.plays')
    end

    expected_values = %w[ALTER AUTHORIZE DROP MODIFY SELECT]
    expected_values.each do |val|
      it do
        is_expected.to contain_cassandra__schema__permission("boone:ALL:ravens.plays - #{val}").with(
          ensure: 'present',
          user_name: 'boone',
          keyspace_name: 'ravens',
          permission_name: val,
          table_name: 'plays'
        )
      end
      read_script =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ALL PERMISSIONS ON TABLE ravens.plays\" '
      read_script += "localhost 9042 | grep ' boone | *boone | .* #{val}$'\""
      script_command = "GRANT #{val} ON TABLE ravens.plays TO boone"
      exec_command = "/usr/bin/scl enable testscl \"/usr/bin/cqlsh   -e \\\"#{script_command}\\\" localhost 9042\""
      it do
        is_expected.to contain_exec(script_command).
          only_with(command: exec_command,
                    unless: read_script,
                    require: 'Exec[::cassandra::schema connection test]')
      end
    end
  end

  context 'REVOKE boone:SELECT:ravens.plays' do
    let(:title) { 'REVOKE boone:SELECT:ravens.plays' }
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

    let(:params) do
      {
        ensure: 'absent',
        user_name: 'boone',
        keyspace_name: 'forty9ers',
        permission_name: 'SELECT',
        use_scl: false,
        scl_name: 'nodefault'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('REVOKE boone:SELECT:ravens.plays')
      read_script =  '/usr/bin/cqlsh   -e "LIST ALL PERMISSIONS ON KEYSPACE forty9ers" '
      read_script += "localhost 9042 | grep ' boone | *boone | .* SELECT$'"
      script_command = 'REVOKE SELECT ON KEYSPACE forty9ers FROM boone'
      exec_command = "/usr/bin/cqlsh   -e \"#{script_command}\" localhost 9042"
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  onlyif: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end

  context 'REVOKE boone:SELECT:ravens.plays with SCL' do
    let(:title) { 'REVOKE boone:SELECT:ravens.plays' }
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

    let(:params) do
      {
        ensure: 'absent',
        user_name: 'boone',
        keyspace_name: 'forty9ers',
        permission_name: 'SELECT',
        use_scl: true,
        scl_name: 'testscl'
      }
    end

    it do
      is_expected.to have_resource_count(9)
      is_expected.to contain_cassandra__schema__permission('REVOKE boone:SELECT:ravens.plays')
      read_script =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ALL PERMISSIONS ON KEYSPACE forty9ers\" '
      read_script += "localhost 9042 | grep ' boone | *boone | .* SELECT$'\""
      script_command = 'REVOKE SELECT ON KEYSPACE forty9ers FROM boone'
      exec_command = "/usr/bin/scl enable testscl \"/usr/bin/cqlsh   -e \\\"#{script_command}\\\" localhost 9042\""
      is_expected.to contain_exec(script_command).
        only_with(command: exec_command,
                  onlyif: read_script,
                  require: 'Exec[::cassandra::schema connection test]')
    end
  end
end
