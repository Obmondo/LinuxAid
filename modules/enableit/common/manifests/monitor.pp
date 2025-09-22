# @summary Class for managing monitoring defaults
#
# @param enable Whether to enable monitoring. Defaults to the value of $::obmondo_monitoring_status.
#
class common::monitor (
  Boolean $enable = $::obmondo_monitoring_status,
) {
  if $enable {
    contain ::monitor
    contain ::common::monitor::exporter
    contain ::common::monitor::prometheus::server
  }
}
