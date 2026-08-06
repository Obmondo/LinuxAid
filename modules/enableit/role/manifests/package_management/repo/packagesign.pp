# @summary Package signing settings, used when `packagesign` is enabled
#
# @param script_tag The tag of the packagesign-script image.
#
# @param signing_password The password used for signing packages.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups signing script_tag, signing_password, encrypt_params
#
# @encrypt_params signing_password
#
class role::package_management::repo::packagesign (
  Optional[String] $script_tag       = undef,
  Optional[String] $signing_password = undef,

  Eit_types::Encrypt::Params $encrypt_params = [
    'signing_password',
  ]
) {
}
