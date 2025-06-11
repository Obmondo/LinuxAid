# A class for installing the DataStax Agent and to point it at an OpsCenter
# instance.
#
# @param address_config_file The full path to the address config file.
# @param defaults_file The full path name to the file where `java_home` is set.
# @param java_home If the value of this variable is left as *undef*, no
#   action is taken.  Otherwise the value is set as JAVA_HOME in
#   `defaults_file`.
# @param package_ensure Is passed to the package reference.  Valid values are
#   **present** or a version number.
# @param package_name Is passed to the package reference.
# @param service_ensure Is passed to the service reference.
# @param service_enable Is passed to the service reference.
# @param service_name Is passed to the service reference.
# @param service_provider The name of the provider that runs the service.
#   If left as *undef* then the OS family specific default will be used,
#   otherwise the specified value will be used instead.
# @param settings A hash that is passed to
#   [create_ini_settings]
#   (https://github.com/puppetlabs/puppetlabs-inifile#function-create_ini_settings)
#   with the following additional defaults:
#
#   ```puppet
#   {
#     path              => $address_config_file,
#     key_val_separator => ': ',
#     require           => Package[$package_name],
#     notify            => Service['datastax-agent'],
#   }
#   ```
#
# @example Set agent_alias to foobar, stomp_interface to localhost and ensure that async_pool_size is absent from the file.
#   class { 'cassandra::datastax_agent':
#     settings => {
#       'agent_alias'     => {
#         'setting' => 'agent_alias',
#         'value'   => 'foobar',
#       },
#       'stomp_interface' => {
#         'setting' => 'stomp_interface',
#         'value'   => 'localhost',
#       },
#       'async_pool_size' => {
#         'ensure' => absent,
#       },
#     },
#   }
class cassandra::datastax_agent (
  $address_config_file  = '/var/lib/datastax-agent/conf/address.yaml',
  $defaults_file        = '/etc/default/datastax-agent',
  $java_home            = undef,
  $package_ensure       = 'present',
  $package_name         = 'datastax-agent',
  $service_ensure       = 'running',
  $service_enable       = true,
  $service_name         = 'datastax-agent',
  $service_provider     = undef,
  $settings             = {},
) inherits cassandra::params {
  require 'cassandra'

  if $service_provider != undef {
    System {
      provider => $service_provider,
    }
  }

  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
    notify  => Exec['datastax_agent_reload_systemctl'],
  }

  exec { 'datastax_agent_reload_systemctl':
    command     => "${cassandra::params::systemctl} daemon-reload",
    onlyif      => "test -x ${cassandra::params::systemctl}",
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    notify      => Service['datastax-agent'],
  }

  file { $address_config_file:
    owner   => 'cassandra',
    group   => 'cassandra',
    mode    => '0644',
    require => Package[$package_name],
  }

  if $java_home != undef {
    ini_setting { 'java_home':
      ensure            => present,
      path              => $defaults_file,
      section           => '',
      key_val_separator => '=',
      setting           => 'JAVA_HOME',
      value             => $java_home,
      notify            => Service['datastax-agent'],
    }
  }

  service { 'datastax-agent':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name,
  }

  if $settings {
    $defaults = {
      path              => $address_config_file,
      key_val_separator => ': ',
      require           => Package[$package_name],
      notify            => Service['datastax-agent'],
    }

    $full_settings = {
      '' => $settings,
    }
    create_ini_settings($full_settings, $defaults)
  }
}
