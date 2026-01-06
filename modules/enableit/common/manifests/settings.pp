# @summary Class for common settings for per customers
#
# @param pgp_keyserver The PGP keyserver hostname or URL.
#
# @param custom_config_dir The absolute path to the custom configuration directory.
#
# @param publicips Optional array of IPs for public interfaces. Defaults to undef.
#
# @param pgp_key_ids Array of GPG key IDs. Defaults to an empty array.
#
# @groups network publicips.
#
# @groups pgp pgp_keyserver, pgp_key_ids.
#
# @groups config custom_config_dir.
#
class common::settings (
  Eit_types::Hostname            $pgp_keyserver,
  Stdlib::Absolutepath           $custom_config_dir,
  Optional[Array[Eit_types::IP]] $publicips          = undef,
  Array[Eit_types::Gpg_key_id]   $pgp_key_ids        = [],
) {
}
