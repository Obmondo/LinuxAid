# == Class: riemann
#
# A module to manage riemann, a monitoring system for distributed systems
#
# === Parameters
# [*version*]
#   The version of riemann to instal
#
# [*config_file*]
#   File path for a riemann config file. A default file is provided. If
#   specified you are responsible for ensuring it exists on disk.
#
# [*host*]
#   Host for the riemann server. Used by the puppet report processor.
#
# [*port*]
#   Port for the riemann server. Used by the puppet report processor.
#
# [*user*]
#   The system user which riemann runs as. Defaults to riemann. Will be
#   created by the module.
#
class riemann(
  Variant[Enum['present', 'absent', 'latest'], String] $ensure = 'present',
  Boolean $enable = true,
  Stdlib::AbsolutePath $config_file,
  Eit_types::Host $host,
  Stdlib::Port $port,
  Eit_types::User $user,
  Eit_types::User $net_user,
) {

  class { 'riemann::install':
    version => $ensure,
    before => Class['riemann::config'],
  }

  class { 'riemann::config':
    ensure => ensure_file($enable),
    before => Class['riemann::service'],
    notify => Class['riemann::service'],
  }

  class { 'riemann::service':
    enable => $enable,
  }
}
