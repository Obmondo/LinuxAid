# =Class perforce::configure
#
# ==Description
# Configures the perforce service via environment file
#
class perforce::configure {

  # create a file of environment variables p4d will use when it starts
  file { '/opt/perforce/.p4config':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('perforce/p4config.epp', {
      'port'    => $perforce::service_port,
      'root'    => $perforce::service_root,
      'name'    => $perforce::service_name,
      'ssldir'  => $perforce::service_ssldir,
      'pidfile' => "${perforce::service_root}/${perforce::service_name}.pid",
    }),
    notify  => Class['Perforce::service'],
  }
}