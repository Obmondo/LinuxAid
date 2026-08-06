# @summary Recovery settings, used when `mode` is 'standby'
#
# @param recovery_username The username for recovery access. Defaults to undef.
#
# @param recovery_password The password for recovery access. Defaults to undef.
#
# @param recovery_host The IP address of the recovery host. Defaults to undef.
#
# @param recovery_port The port for recovery connections. Defaults to 5432.
#
# @param recovery_trigger The trigger file for recovery. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups recovery recovery_username, recovery_password, recovery_host, recovery_port, recovery_trigger, encrypt_params
#
# @encrypt_params recovery_password
#
class role::db::pgsql::mode::standby (
  Optional[Eit_types::SimpleString] $recovery_username = undef,
  Optional[String]                  $recovery_password = undef,
  Optional[Eit_types::IP]           $recovery_host     = undef,
  Optional[Stdlib::Port]            $recovery_port     = 5432,
  Optional[Stdlib::Unixpath]        $recovery_trigger  = undef,

  Eit_types::Encrypt::Params $encrypt_params = [
    'recovery_password',
  ]
) {
}
