# Time
class profile::system::time (
  Eit_types::Timezone $timezone = $common::system::time::timezone,
) inherits ::profile::system {

  class { 'timezone':
    timezone => $timezone,
  }
}
