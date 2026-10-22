# @summary Class for managing Microsoft SCOM monitoring configuration
#
# @param enable Whether to enable SCOM monitoring. When false, the SCOM sudo
#   rules and firewall rule are removed. Defaults to false.
#
# @param noop_value The noop value for testing purposes. Defaults to undef.
#
# @groups settings enable, noop_value
#
class common::monitor::scom (
  Boolean               $enable     = false,
  Eit_types::Noop_Value $noop_value = undef,
) {
  include profile::monitor::scom
}
