# @summary SSL settings for PHP-FPM, used when `ssl` is enabled
#
# @param cert The path to the SSL certificate file. Defaults to undef.
#
# @param key The path to the SSL key file. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups ssl cert, key, encrypt_params
#
# @encrypt_params cert, key
#
class role::appeng::phpfpm::ssl (
  Optional[String] $cert = undef,
  Optional[String] $key  = undef,

  Eit_types::Encrypt::Params $encrypt_params = [
    'cert',
    'key',
  ]
) {
}
