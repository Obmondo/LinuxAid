# @summary Class for managing Microsoft SCOM monitoring configuration
#
# @param enable Whether to enable SCOM monitoring. Defaults to false.
#
# @param noop_value The noop value for testing purposes. Defaults to undef.
#
# @groups settings enable, noop_value
#
class common::monitor::scom (
  Boolean               $enable     = false,
  Eit_types::Noop_Value $noop_value = undef,
) {
  if $enable {
    include profile::monitor::scom
  }
}
