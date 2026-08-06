
# @summary Class for managing PostgreSQL database
#
# @param max_connections The maximum number of connections to allow. Defaults to 100.
#
# @param listen_address An array of IP addresses to listen on. Defaults to ['127.0.0.1'].
#
# @param databases A hash of databases to manage. Defaults to an empty hash.
#
# @param mode The mode in which PostgreSQL will run. Defaults to 'standalone'.
#
# @param pg_hba_rule A hash of pg_hba rules. Defaults to an empty hash.
#
# @param application_name The name of the application. Defaults to undef.
#
# @param backup Boolean to enable backup. Defaults to false.
#
# @groups connection listen_address, max_connections
#
# @groups databases_management databases, pg_hba_rule
#
# @groups operational_mode mode, application_name
#
# @groups backup backup
#
class role::db::pgsql (
  Integer[0, default]                $max_connections      = 100,
  Array[Stdlib::IP::Address]         $listen_address       = ['127.0.0.1'],
  Eit_types::Pgsql::Db               $databases            = {},
  Eit_types::Pgsql::Mode             $mode                 = 'standalone',
  Optional[Eit_types::Pgsql::Pg_hba] $pg_hba_rule          = {},
  Optional[Eit_types::SimpleString]  $application_name     = undef,
  Optional[Boolean]                  $backup               = false,
) inherits ::role::db {

  # contained before the confines and the profile below, which read their parameters
  contain role::db::pgsql::mode::standby
  contain role::db::pgsql::mode::primary

  confine($mode == 'standby',
    (!$role::db::pgsql::mode::standby::recovery_host or !$role::db::pgsql::mode::standby::recovery_trigger),
    '`recovery_host` and `recovery_trigger` is mandatory for recovery.conf, if running postgres as standby mode'
  )

  confine($mode == 'primary',
    (!$role::db::pgsql::mode::primary::replication_username or !$role::db::pgsql::mode::primary::replication_password),
    '`replication_username` and `replication_password` is mandatory if running postgres as primary node'
  )

  confine(
    ($backup and !$databases),
    '`database` must be specified if backup is enabled'
  )

  profile::db::pgsql.contain
}
