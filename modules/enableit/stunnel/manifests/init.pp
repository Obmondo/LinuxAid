# == Class: stunnel
#
# This module sets up SSL encrypted and authenticated tunnels using the
# common application stunnel.
#
# === Parameters
#
# [*package*]
#   The package name that represents the stunnel application on your
#   distribution.  By default we look this value up in a stunnel::data class,
#   which has a list of common answers.
#
# [*service*]
#   The service name that represents the stunnel application on your
#   distribution.  By default we look this value up in a stunnel::data class,
#   which has a list of common answers.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#   By default we look this value up in a stunnel::data class, which has a
#   list of common answers.
#
# === Examples
#
# include stunnel
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
class stunnel (
  String                         $package,
  String                         $service,
  Stdlib::Absolutepath           $conf_dir,
  Optional[Stdlib::Absolutepath] $log_dir,
) {

  package { $package:
    ensure => present,
  }

  file { $conf_dir:
    ensure  => directory,
    require => Package[$package],
    purge   => true,
    recurse => true,
  }

  if $log_dir {
    file { $log_dir:
      ensure =>  'directory',
      owner  => 'root',
      group  => 'root',
      mode   => 'g=rx,o-rwx',
    }
  }

  # This service is enabled by default on Ubuntu 20.04; ensure that it's
  # disabled so that it doesn't clash with other stunnel service.
  service { $service:
    ensure => 'stopped',
    enable => false,
  }

  if $facts['osfamily'] == 'Debian' {
    exec { 'enable stunnel':
      command => 'sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4',
      path    => [ '/bin', '/usr/bin' ],
      onlyif  => 'grep -q ENABLED /etc/default/stunnel4',
      unless  => 'grep -q ENABLED=1 /etc/default/stunnel4',
      require => Package[$package],
      before  => Service[$service],
    }
  }

  unless $facts.dig('systemd') {
    fail('Unsupported operating system')
  }

  file { '/etc/systemd/system/stunnel@.service':
    ensure => present,
    mode   => '0664',
    source => "puppet:///modules/${module_name}/stunnel.service",
    notify => Exec['systemd_reload'],
  }

  exec { 'systemd_reload':
    path        => ['/bin','/sbin'],
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

}
