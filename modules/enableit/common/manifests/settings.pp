# Common setting for per customers
class common::settings (
  Eit_types::Hostname            $pgp_keyserver,
  Stdlib::Absolutepath           $custom_config_dir,
  Optional[Array[Eit_types::IP]] $publicips          = undef,
  Array[Eit_types::Gpg_key_id]   $pgp_key_ids        = [],
) {
}
