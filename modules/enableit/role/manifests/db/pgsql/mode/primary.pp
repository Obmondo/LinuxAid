# @summary Replication settings, used when `mode` is 'primary'
#
# @param replication_username The username for replication access. Defaults to undef.
#
# @param replication_password The password for replication access. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups replication replication_username, replication_password, encrypt_params
#
# @encrypt_params replication_password
#
class role::db::pgsql::mode::primary (
  Optional[Eit_types::SimpleString] $replication_username = undef,
  Optional[String]                  $replication_password = undef,

  Eit_types::Encrypt::Params $encrypt_params = [
    'replication_password',
  ]
) {
}
