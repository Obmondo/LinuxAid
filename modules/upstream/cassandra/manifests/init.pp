# A class for installing the Cassandra package and manipulate settings in the
# configuration file.
#
# @param baseline_settings [hash] If set, this is a baseline of settings that
#   are merged with the `settings` hash.  The values of the `settings`
#   hash overriding the values in this hash.  This is most useful when used
#   with hiera.
# @param cassandra_2356_sleep_seconds [boolean]
#   This will provide a workaround for
#   [CASSANDRA-2356](https://issues.apache.org/jira/browse/CASSANDRA-2356) by
#   sleeping for the specifed number of seconds after an event involving the
#   Cassandra package.  This option is silently ignored on the Red Hat family
#   of operating systems as this bug only affects Debian systems.
# @param cassandra_9822 [boolean] If set to true, this will apply a patch to the init
#   file for the Cassandra service as a workaround for
#   [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).
#   This this bug only affects Debian systems.
# @param cassandra_yaml_tmpl [string] The path to the Puppet template for the
#   Cassandra configuration file.  This allows the user to supply their own
#   customized template.`
# @param commitlog_directory [string] The path to the commitlog directory.
#   If set, the directory will be managed as a Puppet resource.  Do not
#   specify a value here and in the `settings` hash as they are mutually
#   exclusive.
# @param commitlog_directory_mode [string]  The mode for the
#   `commitlog_directory` is ignored unless `commitlog_directory` is
#   specified.
# @param manage_config_file [boolean] Whether or not to manage the cassandra configuration
#   file.
# @param config_file_mode [string] The permissions mode of the cassandra configuration
#   file.
# @param config_path [string] The path to the cassandra configuration file.
# @param data_file_directories [array] The path(s) to the date directory or
#   directories.
#   If set, the directories will be managed as a Puppet resource.  Do not
#   specify a value here and in the `settings` hash as they are mutually
#   exclusive.
# @param data_file_directories_mode [string]  The mode for the
#   `data_file_directories` is ignored unless `data_file_directories` is
#   specified.
# @param dc [string] Sets the value for dc in *config_path*/*snitch_properties_file*
#   http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
#   for more details.
# @param dc_suffix [string] Sets the value for dc_suffix in
#   *config_path*/*snitch_properties_file* see
#   http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
#   for more details.  If the value is *undef* then no change will be made to
#   the snitch properties file for this setting.
# @param fail_on_non_supported_os [boolean] A flag that dictates if the module should
#   fail if it is not RedHat or Debian.  If you set this option to false then
#   you must also at least set the `config_path` attribute as well.
# @param hints_directory [string] The path to the hints directory.
#   If set, the directory will be managed as a Puppet resource.  Do not
#   specify a value here and in the `settings` hash as they are mutually
#   exclusive.  Do not set this option in Cassandra versions before 3.0.0.
# @param hints_directory_mode [string]  The mode for the
#   `hints_directory` is ignored unless `hints_directory` is
#   specified.
# @param package_ensure [present|latest|string] The status of the package specified in
#   **package_name**.  Can be *present*, *latest* or a specific version
#   number.
# @param package_name [string] The name of the Cassandra package which must be available
#   from a repository.
# @param prefer_local [boolean] Sets the value for prefer_local in
#   *config_path*/*snitch_properties_file* see
#   http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
#   for more details.  Valid values are true, false or *undef*.  If the value
#   is *undef* then change will be made to the snitch properties file for
#   this setting.
# @param rack [string] Sets the value for rack in
#   *config_path*/*snitch_properties_file* see
#   http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
#   for more details.
# @param rackdc_tmpl [string] The template for creating the snitch properties file.
# @param saved_caches_directory [string] The path to the saved caches directory.
#   If set, the directory will be managed as a Puppet resource.  Do not
#   specify a value here and in the `settings` hash as they are mutually
#   exclusive.
# @param saved_caches_directory_mode [string]  The mode for the
#   `saved_caches_directory` is ignored unless `saved_caches_directory` is
#   specified.
# @param service_enable [boolean] enable the Cassandra service to start at boot time.
# @param service_ensure [string] Ensure the Cassandra service is running.  Valid values
#   are running or stopped.
# @param service_name [string] The name of the service that runs the Cassandra software.
# @param service_provider [string] The name of the provider that runs the service.
#   If left as *undef* then the OS family specific default will
#   be used, otherwise the specified value will be used instead.
# @param service_refresh [boolean] If set to true, changes to the Cassandra config file
#   or the data directories will ensure that Cassandra service is refreshed
#   after the changes.  Setting this flag to false will disable this
#   behaviour, therefore allowing the changes to be made but allow the user
#   to control when the service is restarted.
# @param settings [hash] A hash that is passed to `to_yaml` which dumps the results
#   to the Cassandra configuring file.  The minimum required settings for
#   Cassandra 2.X are as follows:
#
#   ```puppet
#     {
#       'authenticator'               => 'PasswordAuthenticator',
#       'cluster_name'                => 'MyCassandraCluster',
#       'commitlog_directory'         => '/var/lib/cassandra/commitlog',
#       'commitlog_sync'              => 'periodic',
#       'commitlog_sync_period_in_ms' => 10000,
#       'data_file_directories'       => ['/var/lib/cassandra/data'],
#       'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
#       'listen_address'              => $::ipaddress,
#       'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
#       'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
#       'seed_provider'               => [
#         {
#           'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
#           'parameters' => [
#             {
#               'seeds' => $::ipaddress,
#             },
#           ],
#         },
#       ],
#       'start_native_transport'      => true,
#     }
#   ```
#   For Cassandra 3.X you will also need to specify the `hints_directory`
#   attribute.
# @param snitch_properties_file [string] The name of the snitch properties file.  The
#   full path name would be *config_path*/*snitch_properties_file*.
# @param systemctl [string] The full path to the systemctl command.  Only
#   needed when the package is installed.  Will silently continue if the
#   executable does not exist.
class cassandra (
  $baseline_settings            = {},
  $cassandra_2356_sleep_seconds = 5,
  $cassandra_9822               = false,
  $cassandra_yaml_tmpl          = 'cassandra/cassandra.yaml.erb',
  $commitlog_directory          = undef,
  $commitlog_directory_mode     = '0750',
  Boolean $manage_config_file   = true,
  $config_file_mode             = '0644',
  $config_path                  = $cassandra::params::config_path,
  $data_file_directories        = undef,
  $data_file_directories_mode   = '0750',
  $dc                           = 'DC1',
  $dc_suffix                    = undef,
  $fail_on_non_supported_os     = true,
  $hints_directory              = undef,
  $hints_directory_mode         = '0750',
  $package_ensure               = 'present',
  $package_name                 = $cassandra::params::cassandra_pkg,
  $prefer_local                 = undef,
  $rack                         = 'RAC1',
  $rackdc_tmpl                  = 'cassandra/cassandra-rackdc.properties.erb',
  $saved_caches_directory       = undef,
  $saved_caches_directory_mode  = '0750',
  $service_enable               = true,
  $service_ensure               = undef,
  $service_name                 = 'cassandra',
  $service_provider             = undef,
  $service_refresh              = true,
  $settings                     = {},
  $snitch_properties_file       = 'cassandra-rackdc.properties',
  $systemctl                    = $cassandra::params::systemctl,
) inherits cassandra::params {
  if $service_provider != undef {
    Service {
      provider => $service_provider,
    }
  }

  $config_file = "${config_path}/cassandra.yaml"
  $dc_rack_properties_file = "${config_path}/${snitch_properties_file}"

  case $facts['os']['family'] {
    'RedHat': {
      $config_file_require = Package['cassandra']
      $config_file_before  = []
      $config_path_require = Package['cassandra']
      $dc_rack_properties_file_require = Package['cassandra']
      $dc_rack_properties_file_before  = []
      $data_dir_require = Package['cassandra']
      $data_dir_before = []

      if $facts['os']['release']['major'] == '7' and $cassandra::service_provider == 'init' {
        exec { "/sbin/chkconfig --add ${service_name}":
          unless  => "/sbin/chkconfig --list ${service_name}",
          require => Package['cassandra'],
          before  => Service['cassandra'],
        }
      }
    }
    'Debian': {
      $config_file_require = [User['cassandra'], File[$config_path]]
      $config_file_before  = Package['cassandra']
      $config_path_require = []
      $dc_rack_properties_file_require = [User['cassandra'], File[$config_path]]
      $dc_rack_properties_file_before  = Package['cassandra']
      $data_dir_require = File[$config_file]
      $data_dir_before = Package['cassandra']

      if $cassandra_9822 {
        file { '/etc/init.d/cassandra':
          source => 'puppet:///modules/cassandra/CASSANDRA-9822/cassandra',
          mode   => '0555',
          before => Package['cassandra'],
        }
      }
      # Sleep after package install and before service resource to prevent
      # possible duplicate processes arising from CASSANDRA-2356.
      exec { 'CASSANDRA-2356 sleep':
        command     => "/bin/sleep ${cassandra_2356_sleep_seconds}",
        refreshonly => true,
        user        => 'root',
        subscribe   => Package['cassandra'],
        before      => Service['cassandra'],
      }

      group { 'cassandra':
        ensure => present,
      }

      $user = 'cassandra'

      user { $user:
        ensure     => present,
        comment    => 'Cassandra database,,,',
        gid        => 'cassandra',
        home       => '/var/lib/cassandra',
        shell      => '/bin/false',
        managehome => true,
        require    => Group['cassandra'],
      }
      # End of CASSANDRA-2356 specific resources.
    }
    default: {
      $config_file_before  = [Package['cassandra']]
      $config_file_require = []
      $config_path_require = []
      $dc_rack_properties_file_require = Package['cassandra']
      $dc_rack_properties_file_before  = []

      if $fail_on_non_supported_os {
        fail("OS family ${facts['os']['family']} not supported")
      } else {
        warning("OS family ${facts['os']['family']} not supported")
      }
    }
  }

  package { 'cassandra':
    ensure => $package_ensure,
    name   => $package_name,
    notify => Exec['cassandra_reload_systemctl'],
  }

  exec { 'cassandra_reload_systemctl':
    command     => "${systemctl} daemon-reload",
    onlyif      => "test -x ${systemctl}",
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

  file { $config_path:
    ensure  => directory,
    group   => 'cassandra',
    owner   => 'cassandra',
    mode    => '0755',
    require => $config_path_require,
  }

  if $commitlog_directory {
    file { $commitlog_directory:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $commitlog_directory_mode,
      require => $data_dir_require,
      before  => $data_dir_before,
    }

    $commitlog_directory_settings = merge($settings, { 'commitlog_directory' => $commitlog_directory, })
  } else {
    $commitlog_directory_settings = $settings
  }

  if $data_file_directories =~ Array {
    file { $data_file_directories:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $data_file_directories_mode,
      require => $data_dir_require,
      before  => $data_dir_before,
    }

    $data_file_directories_settings = merge($settings, { 'data_file_directories' => $data_file_directories, })
  } else {
    $data_file_directories_settings = $settings
  }

  if $hints_directory {
    file { $hints_directory:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $hints_directory_mode,
      require => $data_dir_require,
      before  => $data_dir_before,
    }

    $hints_directory_settings = merge($settings, { 'hints_directory' => $hints_directory, })
  } else {
    $hints_directory_settings = $settings
  }

  if $saved_caches_directory {
    file { $saved_caches_directory:
      ensure  => directory,
      owner   => 'cassandra',
      group   => 'cassandra',
      mode    => $saved_caches_directory_mode,
      require => $data_dir_require,
      before  => $data_dir_before,
    }

    $saved_caches_directory_settings = merge($settings, { 'saved_caches_directory' => $saved_caches_directory, })
  } else {
    $saved_caches_directory_settings = $settings
  }

  $merged_settings = merge($baseline_settings, $settings,
    $commitlog_directory_settings,
    $data_file_directories_settings,
    $hints_directory_settings,
  $saved_caches_directory_settings)

  if $manage_config_file {
    file { $config_file:
      ensure  => file,
      owner   => 'cassandra',
      group   => 'cassandra',
      content => template($cassandra_yaml_tmpl),
      mode    => $config_file_mode,
      require => $config_file_require,
      before  => $config_file_before,
    }

    $service_dependencies = [
      File[$config_file],
      File[$dc_rack_properties_file],
      Package['cassandra'],
    ]
  } else {
    $service_dependencies = [
      File[$dc_rack_properties_file],
      Package['cassandra'],
    ]
  }

  file { $dc_rack_properties_file:
    ensure  => file,
    content => template($rackdc_tmpl),
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    require => $dc_rack_properties_file_require,
    before  => $dc_rack_properties_file_before,
  }

  if $package_ensure != 'absent' and $package_ensure != 'purged' {
    if $service_refresh {
      service { 'cassandra':
        ensure    => $service_ensure,
        name      => $service_name,
        enable    => $service_enable,
        subscribe => $service_dependencies,
      }
    } else {
      service { 'cassandra':
        ensure  => $service_ensure,
        name    => $service_name,
        enable  => $service_enable,
        require => $service_dependencies,
      }
    }
  }
}
