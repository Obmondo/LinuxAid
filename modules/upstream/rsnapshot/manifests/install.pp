# == Class: rsnapshot::install
#
# Installs the rsnapshot package.
class rsnapshot::install {
  case $::operatingsystem {
    /^CentOS$/: { include epel }
    default: {}
  }
  package { $rsnapshot::package_name:
    ensure => $rsnapshot::package_ensure,
  }

  # ensure run directory exists (systemd clears /var/run, so rsnapshot can't create PID files after reboot - issue#12)
  $lockpath   = pick($rsnapshot::lockpath, $rsnapshot::params::config_lockpath, '/var/run/rsnapshot')
  $tmpfiles_d = '/etc/tmpfiles.d'
 
  file { "${tmpfiles_d}":
    ensure => directory,
  }

  file { "${tmpfiles_d}/rsnapshot.conf":
    ensure  => present,
    content => "D ${lockpath} 0755 root root -",
  }

}

