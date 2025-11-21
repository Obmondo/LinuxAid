# @summary Class for Obmondo monitoring
#
# @param enable Enable or disable the monitoring. Defaults to the value of $::obmondo_monitoring_status.
#
# @param noop_value No-operation mode value. Defaults to false.
#
class monitor (
  Boolean               $enable     = $::obmondo_monitoring_status, #lint:ignore:top_scope_facts
  Eit_types::Noop_Value $noop_value = undef,
) {
  if $enable {
    contain monitor::prometheus
    contain monitor::raid
    contain monitor::system
    contain monitor::service
  }
}
