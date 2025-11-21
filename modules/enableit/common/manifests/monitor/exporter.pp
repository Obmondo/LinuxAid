# @summary Class for managing the common::monitor::exporter
#
# @param enable Whether to enable the exporter. Defaults to the value of $common::monitor::enable.
#
# @param noop_value The noop value for the exporter. Defaults to false.
#
# @param config_dir The directory for exporter configuration files. Defaults to '/opt/obmondo/etc/exporter'.
#
class common::monitor::exporter (
  Boolean               $enable     = $common::monitor::enable,
  Eit_types::Noop_Value $noop_value = $common::monitor::noop_value,
  Stdlib::Absolutepath  $config_dir = '/opt/obmondo/etc/exporter',
) {
  file { $config_dir :
    ensure => ensure_dir($enable),
    mode   => '0755',
    noop   => $noop_value,
  }

  include common::monitor::exporter::node

  if $enable and $facts['init_system'] == 'systemd' {
    include common::monitor::exporter::dns
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
