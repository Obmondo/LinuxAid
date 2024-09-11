# Prometheus Exporter
class common::monitor::exporter (
  Boolean              $enable     = $common::monitor::enable,
  Optional[Boolean]    $noop_value = false,
  Stdlib::Absolutepath $config_dir = '/opt/obmondo/etc/exporter',
) {

  file { $config_dir :
    ensure => ensure_dir($enable),
    mode   => '0755',
    noop   => $noop_value,
  }

  if $enable and $facts['init_system'] == 'systemd' {
    include common::monitor::exporter::node
    include common::monitor::exporter::dns
    include common::monitor::exporter::pushprox
    include common::monitor::exporter::dellhw
    include common::monitor::exporter::iptables
    include common::monitor::exporter::systemd
    include common::monitor::exporter::mtail
    include common::monitor::exporter::process
    include common::monitor::exporter::filestat
    include common::monitor::exporter::security
    include common::monitor::exporter::blackbox
  }
}
