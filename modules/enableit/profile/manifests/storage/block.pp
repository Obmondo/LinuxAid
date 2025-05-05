# Storage Block profile
class profile::storage::block (
  Hash[
    String,
    Struct[{
      device                             => Stdlib::Absolutepath,
      Optional[target]                   => Stdlib::Absolutepath,
      Optional[mount]                    => Boolean,
      Optional[use_luks]                 => Boolean,
      Optional[luks_secret]              => String[1],
      Optional[luks_key_service]         => Eit_types::URL,
      Optional[luks_key_service_headers] => Hash[String, String],
    }]
  ] $devices = {},
) {

  confine(!($facts['init_system'] in ['systemd']), 'Only systemd is supported')
  stdlib::ensure_packages(['curl'])
  create_resources('common::luks', $devices)
}
