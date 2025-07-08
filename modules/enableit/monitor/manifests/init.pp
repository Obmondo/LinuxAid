# @summary Class for Obmondo monitoring
#
# @param enable Enable or disable the monitoring. Defaults to the value of $::obmondo_monitoring_status.
#
# @param noop_value No-operation mode value. Defaults to false.
#
class monitor (
  Boolean $enable     = $::obmondo_monitoring_status,
  Boolean $noop_value = false,
) {
  if $enable {
    contain monitor::prometheus
    contain monitor::raid
    contain monitor::system
    contain monitor::service
  }
}
