# @summary Class for managing the Topprocesses Prometheus exporter
#
# @param enable Enable or disable the exporter. Defaults to the value of $common::monitor::exporter::node::enable.
#
# @param noop_value Optional. The value for noop attribute. Defaults to false.
#
class common::monitor::exporter::node::topprocesses (
  Boolean           $enable     = $common::monitor::exporter::node::enable,
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

  package {'obmondo-topprocesses-textfile-exporter':
    ensure  => ensure_latest($enable),
    require => if $enable { Package['obmondo-node-exporter'] },
  }

  file { "${textfile_directory}/topprocesses.prom" :
    ensure  => ensure_file($enable),
    require => if $enable { Package['obmondo-topprocesses-textfile-exporter'] },
  }

  service { 'top_processes_textfile_exporter.timer':
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['obmondo-topprocesses-textfile-exporter'],
  }
}
