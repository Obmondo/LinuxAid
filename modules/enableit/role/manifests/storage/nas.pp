# Storage Nas role
class role::storage::nas (
  Hash[
    String,
    Struct[{
      device                             => String[1],
      target                             => Optional[Stdlib::Absolutepath],
      mount                              => Optional[Boolean],
      use_luks                           => Optional[Boolean],
      luks_secret                        => Optional[String[1]],
      luks_key_service                   => Optional[Eit_types::URL],
      luks_key_service_headers           => Optional[Hash[String, String]]
    }]
  ] $devices = {},
  Boolean $backuphost = true,
) inherits role::storage {

  confine(!($facts['init_system'] in ['systemd']), 'Only systemd is supported')

  class { 'profile::storage::block':
    devices => $devices,
  }

  if $backuphost {
    class { 'profile::storage::backuphost': }
  }

}
