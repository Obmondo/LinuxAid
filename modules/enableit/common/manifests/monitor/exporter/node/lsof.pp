# Lsof exporter for Prometheus
class common::monitor::exporter::node::lsof (
  Boolean           $enable     = $::common::monitor::exporter::node::enable,
  Optional[Boolean] $noop_value = false,
) {

  File {
    noop => $noop_value,
  }
  Package {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }

  $textfile_directory = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)

  package { 'obmondo-lsof-textfile-exporter' :
    ensure  =>  ensure_latest($enable),
    require => Package['obmondo-node-exporter'] ,
  }

  file { "${textfile_directory}/check_deleted_open_files.prom" :
    ensure  =>  ensure_present($enable),
    require => Package['obmondo-lsof-textfile-exporter'],
  }

  service {'obmondo-lsof-textfile-exporter.timer' :
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['obmondo-lsof-textfile-exporter'],
  }
}
