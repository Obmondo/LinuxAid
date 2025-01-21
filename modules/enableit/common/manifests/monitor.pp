# Monitoring defaults
class common::monitor (
  Boolean $enable = $::obmondo_monitoring_status,
) {
  if $enable {
    contain ::monitor
    contain ::common::monitor::exporter
    contain ::common::monitor::prom::server
  }
}
