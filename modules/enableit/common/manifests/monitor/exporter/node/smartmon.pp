# @summary Class for managing the Prometheus Smartmon class common::monitor::exporter::node::smartmon
#
# @param enable Boolean to enable or disable the class. Defaults to $common::monitor::exporter::node::enable.
#
# @param noop_value Optional Boolean for no-operation mode. Defaults to false.
#
class common::monitor::exporter::node::smartmon (
  Boolean $enable = $common::monitor::exporter::node::enable,
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

  $_enable = $facts.dig('raidcontrollers') == undef and $facts.dig('virtual') == 'physical'

  package {
    ['obmondo-smartmon-textfile-collector', 'smartmontools']:
      ensure  => ensure_latest($_enable),
      require => if $_enable { Package['obmondo-node-exporter'] },
  }

  file { "${textfile_directory}/smartmon.prom" :
    ensure  => ensure_file($_enable),
    require => if $_enable { Package['obmondo-smartmon-textfile-collector'] },
  }

  service { 'smartmon_textfile_collector.timer':
    ensure  => ensure_service($_enable),
    enable  => $_enable,
    require => Package['obmondo-smartmon-textfile-collector'],
  }
}
