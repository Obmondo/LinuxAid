require 'spec_helper'

describe 'cassandra::datastax_agent' do
  context 'Test for cassandra::datastax_agent with defaults (RedHat).' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '6',
        os: {
          'name'    => 'RedHat',
          'family'  => 'RedHat',
          'release' => {
            'full'  => '6.10',
            'major' => '6',
            'minor' => '10'
          }
        }
      }
    end

    it do
      is_expected.to compile.with_all_deps

      is_expected.to have_resource_count(10)

      is_expected.to contain_class('cassandra::datastax_agent').with(
        'address_config_file'  => '/var/lib/datastax-agent/conf/address.yaml',
        'defaults_file'        => '/etc/default/datastax-agent',
        'package_ensure'       => 'present',
        'package_name'         => 'datastax-agent',
        'service_ensure'       => 'running',
        'service_enable'       => true,
        'service_name'         => 'datastax-agent',
        'settings'             => {}
      )

      is_expected.to contain_package('datastax-agent').with(
        ensure: 'present',
        notify: 'Exec[datastax_agent_reload_systemctl]'
      ).that_notifies('Exec[datastax_agent_reload_systemctl]')

      is_expected.to contain_exec('datastax_agent_reload_systemctl').only_with(
        command: '/usr/bin/systemctl daemon-reload',
        onlyif: 'test -x /usr/bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true,
        notify: 'Service[datastax-agent]'
      ).that_notifies('Service[datastax-agent]')

      is_expected.to contain_file('/var/lib/datastax-agent/conf/address.yaml').
        with(
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        ).that_requires('Package[datastax-agent]')

      is_expected.to contain_service('datastax-agent').only_with(
        ensure: 'running',
        enable: true,
        name: 'datastax-agent'
      )
    end
  end

  context 'Test for cassandra::datastax_agent with defaults (Debian).' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemmajrelease: '7',
        os: {
          'family'  => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    it do
      is_expected.to contain_exec('datastax_agent_reload_systemctl').with(
        command: '/bin/systemctl daemon-reload',
        onlyif: 'test -x /bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true
      ).that_notifies('Service[datastax-agent]')
    end
  end

  context 'Test that the JAVA_HOME can be set.' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemmajrelease: '7',
        os: {
          'family'  => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    let :params do
      {
        java_home: '/usr/lib/jvm/java-8-oracle'
      }
    end

    it do
      is_expected.to contain_ini_setting('java_home').with(
        ensure: 'present',
        path: '/etc/default/datastax-agent',
        section: '',
        key_val_separator: '=',
        setting: 'JAVA_HOME',
        value: '/usr/lib/jvm/java-8-oracle'
      ).that_notifies('Service[datastax-agent]')
    end
  end

  context 'Test settings.' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemmajrelease: '7',
        os: {
          'family'  => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    let :params do
      {
        settings: {
          'agent_alias' => {
            'setting' => 'agent_alias',
            'value'   => 'foobar'
          },
          'stomp_interface' => {
            'setting' => 'stomp_interface',
            'value'   => 'localhost'
          },
          'async_pool_size' => {
            'ensure' => 'absent'
          }
        }
      }
    end

    it do
      is_expected.to have_resource_count(16)
    end
  end
end
