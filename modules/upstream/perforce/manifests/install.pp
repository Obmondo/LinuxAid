#
#
class perforce::install {

  $_perforce_daemon = "${perforce::install_root}/sbin/p4d"
  $_perforce_daemon_suffix = $perforce::version.regsubst(/^20([0-9]{2}\.[0-9]+)-[0-9]+$/, '\1')
  # Newer versions of Perforce seems to put the daemon in a file with a version
  # suffix, e.g. `p4d.19-1`; we'll create and use a symlink.
  $_perforce_daemon_real = "${_perforce_daemon}.${_perforce_daemon_suffix}"

  # systemd template
  file { '/etc/systemd/system/p4d.service':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('perforce/p4d.service.epp', {
      'user'         => $perforce::user,
      'pidfile'      => "${perforce::service_root}/${perforce::service_name}.pid",
      'install_root' => $perforce::install_root,
    }),
    notify  => Exec['systemd refresh p4d.service'],
  }

  file { $_perforce_daemon:
    ensure => 'link',
    target => $_perforce_daemon_real,
  }

  exec { 'systemd refresh p4d.service':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
    require     => [
      Package[$perforce::packages],
      File[$_perforce_daemon],
    ],
    before      => Service['p4d'],
  }
}
