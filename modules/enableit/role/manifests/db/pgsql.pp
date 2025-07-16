
# @summary Class for managing PostgreSQL database
#
# @param allow_remote_hosts An array of IP addresses that are allowed to connect remotely. Defaults to an empty array.
#
# @param max_connections The maximum number of connections to allow. Defaults to 100.
#
# @param listen_address An array of IP addresses to listen on. Defaults to ['127.0.0.1'].
#
# @param databases A hash of databases to manage. Defaults to an empty hash.
#
# @param mode The mode in which PostgreSQL will run. Defaults to 'standalone'.
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
# @param pg_hba_rule A hash of pg_hba rules. Defaults to an empty hash.
#
# @param replication_username The username for replication access. Defaults to undef.
#
# @param replication_password The password for replication access. Defaults to undef.
#
# @param application_name The name of the application. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class role::db::pgsql (
  Array[Stdlib::IP::Address]         $allow_remote_hosts   = [],
  Integer[0, default]                $max_connections      = 100,
  Array[Stdlib::IP::Address]         $listen_address       = ['127.0.0.1'],
  Eit_types::Pgsql::Db               $databases            = {},
  Eit_types::Pgsql::Mode             $mode                 = 'standalone',
  Optional[Eit_types::SimpleString]  $recovery_username    = undef,
  Optional[String]                   $recovery_password    = undef,
  Optional[Eit_types::IP]            $recovery_host        = undef,
  Optional[Stdlib::Port]             $recovery_port        = 5432,
  Optional[Stdlib::Unixpath]         $recovery_trigger     = undef,
  Optional[Eit_types::Pgsql::Pg_hba] $pg_hba_rule          = {},
  Optional[Eit_types::SimpleString]  $replication_username = undef,
  Optional[String]                   $replication_password = undef,
  Optional[Eit_types::SimpleString]  $application_name     = undef,
  Optional[Boolean]                  $backup               = false,
  Eit_types::Encrypt::Params         $encrypt_params            = [
    'recovery_password',
    'replication_password',
  ]

) inherits ::role::db {

  confine(
    Boolean(size($allow_remote_hosts)),
    $listen_address in ['127.0.0.1'],
    '`$allow_remote_hosts` cannot be used unless `$listen_ip` is non-localhost'
  )

  confine($mode == 'standby',
    (!$recovery_host or !$recovery_trigger),
    '`recovery_host` and `recovery_trigger` is mandatory for recovery.conf, if running postgres as standby mode'
  )

  confine($mode == 'primary',
    (!$replication_username or !$replication_password),
    '`replication_username` and `replication_password` is mandatory if running postgres as primary node'
  )

  confine(
    ($backup and !$databases),
    '`database` must be specified if backup is enabled'
  )

  profile::db::pgsql.contain
}
