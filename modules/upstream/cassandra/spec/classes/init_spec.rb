require 'spec_helper'

describe 'cassandra' do
  context 'On an unknown OS with defaults for all parameters' do
    let :facts do
      {
        operatingsystemmajrelease: '16',
        osfamily: 'Darwin',
        os: {
          'family'  => 'Darwin',
          'release' => {
            'full'  => '16.0.0',
            'major' => '16',
            'minor' => '0'
          }
        }
      }
    end

    it { is_expected.to raise_error(Puppet::Error) }
  end

  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '7',
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

    it do
      is_expected.to contain_package('cassandra').with(
        ensure: 'present',
        name: 'cassandra22'
      ).that_notifies('Exec[cassandra_reload_systemctl]')

      is_expected.to contain_exec('cassandra_reload_systemctl').only_with(
        command: '/usr/bin/systemctl daemon-reload',
        onlyif: 'test -x /usr/bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true
      )

      is_expected.to contain_file('/etc/cassandra/default.conf').with(
        ensure: 'directory',
        group: 'cassandra',
        owner: 'cassandra',
        mode: '0755'
      ).that_requires('Package[cassandra]')

      is_expected.to contain_file('/etc/cassandra/default.conf/cassandra.yaml').
        with(
          ensure: 'file',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        ).
        that_requires('Package[cassandra]')

      is_expected.to contain_class('cassandra').only_with(
        baseline_settings: {},
        cassandra_2356_sleep_seconds: 5,
        cassandra_9822: false,
        cassandra_yaml_tmpl: 'cassandra/cassandra.yaml.erb',
        commitlog_directory_mode: '0750',
        manage_config_file: true,
        config_file_mode: '0644',
        config_path: '/etc/cassandra/default.conf',
        data_file_directories_mode: '0750',
        dc: 'DC1',
        fail_on_non_supported_os: true,
        hints_directory_mode: '0750',
        package_ensure: 'present',
        package_name: 'cassandra22',
        rack: 'RAC1',
        rackdc_tmpl: 'cassandra/cassandra-rackdc.properties.erb',
        saved_caches_directory_mode: '0750',
        service_enable: true,
        service_name: 'cassandra',
        service_provider: nil,
        service_refresh: true,
        settings: {},
        snitch_properties_file: 'cassandra-rackdc.properties',
        systemctl: '/usr/bin/systemctl'
      )
    end
  end

  context 'On RedHat 7 with data directories specified.' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '7',
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
        commitlog_directory: '/var/lib/cassandra/commitlog',
        data_file_directories: ['/var/lib/cassandra/data'],
        hints_directory: '/var/lib/cassandra/hints',
        saved_caches_directory: '/var/lib/cassandra/saved_caches',
        settings: { 'cluster_name' => 'MyCassandraCluster' }
      }
    end

    it do
      is_expected.to have_resource_count(10)
      is_expected.to contain_file('/var/lib/cassandra/commitlog')
      is_expected.to contain_file('/var/lib/cassandra/data')
      is_expected.to contain_file('/var/lib/cassandra/hints')
      is_expected.to contain_file('/var/lib/cassandra/saved_caches')
    end
  end

  context 'On RedHat 7 with service provider set to init.' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '7',
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
        service_provider: 'init'
      }
    end

    it do
      is_expected.to have_resource_count(7)
      is_expected.to contain_exec('/sbin/chkconfig --add cassandra').with(
        unless: '/sbin/chkconfig --list cassandra'
      ).
        that_requires('Package[cassandra]').
        that_comes_before('Service[cassandra]')
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        operatingsystemmajrelease: '8',
        osfamily: 'Debian',
        os: {
          'family'  => 'Debian',
          'release' => {
            'full'  => '8.11',
            'major' => '8',
            'minor' => '11'
          }
        }
      }
    end

    it do
      is_expected.to contain_class('cassandra')
      is_expected.to contain_group('cassandra').with_ensure('present')

      is_expected.to contain_package('cassandra').with(
        ensure: 'present',
        name: 'cassandra'
      ).that_notifies('Exec[cassandra_reload_systemctl]')

      is_expected.to contain_exec('cassandra_reload_systemctl').only_with(
        command: '/bin/systemctl daemon-reload',
        onlyif: 'test -x /bin/systemctl',
        path: ['/usr/bin', '/bin'],
        refreshonly: true
      )

      is_expected.to contain_service('cassandra').with(
        ensure: nil,
        name: 'cassandra',
        enable: 'true'
      )

      is_expected.to contain_exec('CASSANDRA-2356 sleep').
        with(
          command: '/bin/sleep 5',
          refreshonly: true,
          user: 'root'
        ).
        that_subscribes_to('Package[cassandra]').
        that_comes_before('Service[cassandra]')

      is_expected.to contain_user('cassandra').
        with(
          ensure: 'present',
          comment: 'Cassandra database,,,',
          gid: 'cassandra',
          home: '/var/lib/cassandra',
          shell: '/bin/false',
          managehome: true
        ).
        that_requires('Group[cassandra]')

      is_expected.to contain_file('/etc/cassandra').with(
        ensure: 'directory',
        group: 'cassandra',
        owner: 'cassandra',
        mode: '0755'
      )

      is_expected.to contain_file('/etc/cassandra/cassandra.yaml').
        with(
          ensure: 'file',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        ).
        that_comes_before('Package[cassandra]').
        that_requires(['User[cassandra]', 'File[/etc/cassandra]'])

      is_expected.to contain_file('/etc/cassandra/cassandra-rackdc.properties').
        with(
          ensure: 'file',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        ).
        that_requires(['File[/etc/cassandra]', 'User[cassandra]']).
        that_comes_before('Package[cassandra]')

      is_expected.to contain_service('cassandra').
        that_subscribes_to(
          [
            'File[/etc/cassandra/cassandra.yaml]',
            'File[/etc/cassandra/cassandra-rackdc.properties]',
            'Package[cassandra]'
          ]
        )
    end
  end

  context 'CASSANDRA-9822 activated on Ubuntu 16.04' do
    let :facts do
      {
        operatingsystemmajrelease: '16.04',
        osfamily: 'Debian',
        lsbdistid: 'Ubuntu',
        lsbdistrelease: '16.04',
        os: {
          'name'    => 'Ubuntu',
          'family'  => 'Debian',
          'release' => {
            'full'  => '16.04',
            'major' => '16.04'
          }
        }
      }
    end

    let :params do
      {
        cassandra_9822: true
      }
    end

    it do
      is_expected.to contain_file('/etc/init.d/cassandra').with(
        source: 'puppet:///modules/cassandra/CASSANDRA-9822/cassandra',
        mode: '0555'
      ).that_comes_before('Package[cassandra]')
    end
  end

  context 'Install DSE on a Red Hat family OS.' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
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
        package_ensure: '4.7.0-1',
        package_name: 'dse-full',
        config_path: '/etc/dse/cassandra',
        service_name: 'dse'
      }
    end

    it do
      is_expected.to contain_file('/etc/dse/cassandra/cassandra.yaml').that_notifies('Service[cassandra]')
      is_expected.to contain_file('/etc/dse/cassandra')

      is_expected.to contain_file('/etc/dse/cassandra/cassandra-rackdc.properties').
        with(
          ensure: 'file',
          owner: 'cassandra',
          group: 'cassandra',
          mode: '0644'
        ).
        that_notifies('Service[cassandra]')

      is_expected.to contain_package('cassandra').with(
        ensure: '4.7.0-1',
        name: 'dse-full'
      )
      is_expected.to contain_service('cassandra').with_name('dse')
    end
  end

  context 'On an unsupported OS pleading tolerance' do
    let :facts do
      {
        operatingsystemmajrelease: '16',
        osfamily: 'Darwin',
        os: {
          'family'  => 'Darwin',
          'release' => {
            'full'  => '16.0.0',
            'major' => '16',
            'minor' => '0'
          }
        }
      }
    end
    let :params do
      {
        config_file_mode: '0755',
        config_path: '/etc/cassandra',
        fail_on_non_supported_os: false,
        package_name: 'cassandra',
        service_provider: 'base',
        systemctl: '/bin/true'
      }
    end

    it do
      is_expected.to contain_file('/etc/cassandra/cassandra.yaml').with('mode' => '0755')
      is_expected.to contain_service('cassandra').with(provider: 'base')
      is_expected.to have_resource_count(6)
    end
  end

  context 'Ensure cassandra service can be stopped and disabled.' do
    let :facts do
      {
        operatingsystemmajrelease: '8',
        osfamily: 'Debian',
        os: {
          'family'  => 'Debian',
          'release' => {
            'full'  => '8.11',
            'major' => '8',
            'minor' => '11'
          }
        }
      }
    end

    let :params do
      {
        service_ensure: 'stopped',
        service_enable: 'false'
      }
    end

    it do
      is_expected.to contain_service('cassandra').
        with(ensure: 'stopped',
             name: 'cassandra',
             enable: 'false')
    end
  end

  context 'Test the dc and rack properties with defaults (Debian).' do
    let :facts do
      {
        operatingsystemmajrelease: '8',
        osfamily: 'Debian',
        os: {
          'family'  => 'Debian',
          'release' => {
            'full'  => '8.11',
            'major' => '8',
            'minor' => '11'
          }
        }
      }
    end

    it do
      is_expected.to contain_file('/etc/cassandra/cassandra-rackdc.properties').
        with_content(%r{^dc=DC1}).
        with_content(%r{^rack=RAC1$}).
        with_content(%r{^#dc_suffix=$}).
        with_content(%r{^# prefer_local=true$})
    end
  end

  context 'Test the dc and rack properties with defaults (RedHat).' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
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
      is_expected.to contain_file('/etc/cassandra/default.conf/cassandra-rackdc.properties').
        with_content(%r{^dc=DC1}).
        with_content(%r{^rack=RAC1$}).
        with_content(%r{^#dc_suffix=$}).
        with_content(%r{^# prefer_local=true$})
    end
  end

  context 'Test the dc and rack properties.' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
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
        snitch_properties_file: 'cassandra-topology.properties',
        dc: 'NYC',
        rack: 'R101',
        dc_suffix: '_1_cassandra',
        prefer_local: 'true'
      }
    end

    it do
      is_expected.to contain_file('/etc/cassandra/default.conf/cassandra-topology.properties').
        with_content(%r{^dc=NYC$}).
        with_content(%r{^rack=R101$}).
        with_content(%r{^dc_suffix=_1_cassandra$}).
        with_content(%r{^prefer_local=true$})
    end
  end
end
