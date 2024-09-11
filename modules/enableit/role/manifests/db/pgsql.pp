# PGsql role
class role::db::pgsql (
  Array[Stdlib::IP::Address]         $allow_remote_hosts   = [],
  Integer[0, default]                $max_connections      = 100,
  Array[Stdlib::IP::Address]         $listen_address       = [
    '127.0.0.1',
  ],
  Eit_types::Pgsql::Db               $databases            = {},
  Eit_types::Pgsql::Mode             $mode                 = 'standalone',
  Optional[Eit_types::SimpleString]  $recovery_username    = undef,
  Optional[Eit_types::SimpleString]  $recovery_password    = undef,
  Optional[Eit_types::IP]            $recovery_host        = undef,
  Optional[Stdlib::Port]             $recovery_port        = 5432,
  Optional[Stdlib::Unixpath]         $recovery_trigger     = undef,
  Optional[Eit_types::Pgsql::Pg_hba] $pg_hba_rule          = {},
  Optional[Eit_types::SimpleString]  $replication_username = undef,
  Optional[Eit_types::SimpleString]  $replication_password = undef,
  Optional[Eit_types::SimpleString]  $application_name     = undef,
) inherits ::role::db {

  confine(
    Boolean(size($allow_remote_hosts)),
    $listen_address in ['127.0.0.1'],
    '`$allow_remote_hosts` cannot be used unless `$listen_ip` is non-localhost')

  confine($mode == 'standby',
    (!$recovery_host or !$recovery_trigger),
    '`recovery_host` and `recovery_trigger` is mandatory for recovery.conf, if running postgres as standby mode')

  confine($mode == 'primary',
    (!$replication_username or !$replication_password),
    '`replication_username` and `replication_password` is mandatory if running postgres as primary node')

  profile::db::pgsql.contain
}
