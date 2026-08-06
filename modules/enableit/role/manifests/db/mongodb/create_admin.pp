# @summary Admin user settings for MongoDB, used when `create_admin` is enabled
#
# @param admin_username The username for the admin user. Defaults to undef.
#
# @param admin_password The password for the admin user. Defaults to undef.
#
# @param admin_roles The roles for the admin user. Defaults to ['root'].
#
# @param admin_store_credentials Whether to store credentials for the admin user. Defaults to false.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups admin admin_username, admin_password, admin_roles, admin_store_credentials, encrypt_params
#
# @encrypt_params admin_password
#
class role::db::mongodb::create_admin (
  Optional[String]              $admin_username          = undef,
  Optional[Eit_types::Password] $admin_password          = undef,
  Array[String]                 $admin_roles             = ['root'],
  Boolean                       $admin_store_credentials = false,

  Eit_types::Encrypt::Params $encrypt_params = [
    'admin_password',
  ]
) {
}
