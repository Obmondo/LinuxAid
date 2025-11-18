# =Class perforce::configure
#
# ==Description
# Configures the perforce service via environment file
#
class perforce::configure {

  user { $perforce::user:
    ensure     => present,
    home       => $perforce::var_dir,
    shell      => '/bin/false',
    managehome => true,
    system     => true,
  }

  group { $perforce::group:
    ensure => present,
    system => true,
  }

  file { $perforce::service_root:
    ensure  => directory,
    owner   => $perforce::user,
    group   => $perforce::group,
    mode    => '0750',
    require => User[$perforce::user],
  }

  file { $perforce::service_log_dir:
    ensure  => directory,
    owner   => $perforce::user,
    group   => 'perforce',
    mode    => '0770',
    require => [
      Group['perforce'],
      User[$perforce::user],
    ],
  }

  # create a file of environment variables p4d will use when it starts
  file { '/opt/perforce/.p4config':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('perforce/p4config.epp', {
      'port'      => $perforce::service_port,
      'root'      => $perforce::service_root,
      'name'      => $perforce::service_name,
      'ssldir'    => $perforce::service_ssldir,
      'pidfile'   => "${perforce::var_dir}/${perforce::service_name}.pid",
      'log'       => $perforce::service_log,
      'log_level' => $perforce::service_log_level,
    }),
    notify  => Service['p4d'],
  }

  file { '/etc/perforce/p4dctl.conf':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    source => 'puppet:///modules/perforce/p4dctl.conf',
    notify => Service['p4d'],
  }

  file { '/etc/perforce/p4dctl.conf.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
  }

  file { "/etc/perforce/p4dctl.conf.d/${facts['hostname']}.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => epp('perforce/p4dctl-p4d.conf.epp', {
      'enable_maintenance' => true,
      'user'               => $perforce::user,
      'port'               => $perforce::service_port,
      'root'               => $perforce::service_root,
      'server_name'        => $perforce::server_name,
      'ssldir'             => $perforce::service_ssldir,
    }),
    require => File['/etc/perforce/p4dctl.conf.d'],
    notify  => Service['p4d'],
  }
}
