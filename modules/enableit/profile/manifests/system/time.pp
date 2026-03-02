# Time
class profile::system::time (
  Eit_types::Timezone $timezone = $common::system::time::timezone,
) {

  class { 'timezone':
    timezone => $timezone,
  }
}
