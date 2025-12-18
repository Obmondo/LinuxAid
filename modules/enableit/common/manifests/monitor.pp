# @summary Class for managing monitoring defaults
#
# @param enable Whether to enable monitoring. Defaults to the value of $::obmondo_monitoring_status.
#
class common::monitor (
  Boolean               $enable     = $::obmondo_monitoring_status, #lint:ignore:top_scope_facts
  Eit_types::Noop_Value $noop_value = undef,
) {
  if $enable {
    contain ::monitor
    contain ::common::monitor::prometheus
  }
}
