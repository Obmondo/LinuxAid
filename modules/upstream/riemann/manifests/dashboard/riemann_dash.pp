# == Class: riemann::dash
#
# A module to manage the riemann dashboard,
# a monitoring system for distributed systems
#
# === Parameters
#
# [*host*]
#   Host for the riemann dashboard. Defaults to localhost
#
# [*port*]
#   Port for the riemann server. Defaults to 4567
#
# [*user*]
#   The system user which riemann-dash runs as. Defaults to riemann-dash.
#   Will be created by the module.
#
# [*rvm_ruby_string*]
#   The RVM Ruby version which should be used. Defaults to undef.
#
class riemann::dashboard::riemann_dash (
  Boolean $enable = false,
  Eit_types::Host $host,
  Stdlib::Port $port,
  Eit_types::User $user,
) {

  $_packages = [
    lookup('riemann::install::libxml_package'),
    lookup('riemann::install::libxslt_package'),
  ]

  ensure_packages($_packages)

  if $facts['os']['family'] == 'RedHat' {
    yum::group { 'Development Tools':
      ensure => present,
    }
  }

  user { 'riemann-dash':
    ensure => present,
    system => true,
  }

  package { 'riemann-dash':
    ensure   => installed,
    provider => gem,
  }

  file { '/etc/systemd/system/riemann-dash.service':
    ensure => file,
    source => 'puppet:///modules/riemann/riemann-dash.service',
  }

  service { 'riemann-dash':
    ensure => running,
    enable => true,
  }

  Package[$_packages]
  ->User['riemann-dash']
  ->File['/etc/systemd/system/riemann-dash.service']
  ~>Service['riemann-dash']
}
