# Time
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
