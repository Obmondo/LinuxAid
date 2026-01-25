# @summary Class for managing monitoring defaults
#
# @param enable Whether to enable monitoring. Defaults to the value of $::obmondo_monitoring_status.
#
# @param noop_value Boolean value for noop mode. Defaults to undef.
#
# @groups settings enable, noop_value
#
class common::monitor (
  Boolean               $manage     = $::obmondo_monitoring_status,
  Boolean               $enable     = $::obmondo_monitoring_status,
  Eit_types::Noop_Value $noop_value = undef,
) {
  if $enable {
    contain ::monitor
    contain ::common::monitor::prometheus

    if lookup('common::monitor::splunk::forwarder::manage', Boolean, undef, false) {
      include common::monitoring::splunk::forwarder
    }
    if lookup('common::monitor::scom::manage', Boolean, undef, false) {
      include common::monitoring::scom
    }
  }
}
