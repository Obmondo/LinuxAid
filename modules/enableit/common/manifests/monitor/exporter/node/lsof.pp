# @summary Class for managing the Lsof exporter for Prometheus
#
# @param enable Whether to enable the exporter. Defaults to the value of $::common::monitor::exporter::node::enable.
#
# @param noop_value Optional boolean to control noop behavior. Defaults to false.
#
class common::monitor::exporter::node::lsof (
  Boolean $enable = $::common::monitor::exporter::node::enable,
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
    ensure  => ensure_latest($enable),
    require => Package['obmondo-node-exporter'],
  }
  file { "${textfile_directory}/check_deleted_open_files.prom" :
    ensure  => ensure_present($enable),
    require => Package['obmondo-lsof-textfile-exporter'],
  }
  service { 'obmondo-lsof-textfile-exporter.timer' :
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['obmondo-lsof-textfile-exporter'],
  }
}
