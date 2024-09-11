# Storage Nas role
class role::storage::nas (
  Hash[
    String,
    Struct[{
      device                             => String[1],
      Optional[target]                   => Stdlib::Absolutepath,
      Optional[mount]                    => Boolean,
      Optional[use_luks]                 => Boolean,
      Optional[luks_secret]              => String[1],
      Optional[luks_key_service]         => Eit_types::URL,
      Optional[luks_key_service_headers] => Hash[String, String],
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
