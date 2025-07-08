# @summary Class for managing system time settings
#
# @param manage_timezone Boolean to determine if timezone management should be enabled. Defaults to true.
#
# @param manage_ntp Boolean to determine if NTP management should be enabled. Defaults to false.
#
# @param timezone The timezone to set. Defaults to 'Europe/Copenhagen'.
#
class common::system::time (
  Boolean             $manage_timezone = true,
  Boolean             $manage_ntp      = false,
  Eit_types::Timezone $timezone        = 'Europe/Copenhagen',
) inherits ::common::system {
  if $manage_timezone {
    contain ::profile::system::time
  }
  if $manage_ntp {
    contain ::common::system::time::ntp
  }
}
