
# @summary Class for managing MySQL database configurations
#
# @param root_password The root password for the MySQL database.
#
# @param datadir The data directory for MySQL. Defaults to '/var/lib/mysql'.
#
# @param memlimit The memory limit percentage for MySQL. Defaults to 75.
#
# @param mysql_restart_on_config_change Boolean indicating whether to restart MySQL on configuration changes. Defaults to false.
#
# @param backup Boolean indicating whether to enable backup. Defaults to true.
#
# @param binlog Boolean indicating whether to enable binary logging. Defaults to true.
#
# @param local_tcp_root_access Boolean indicating whether to allow local TCP root access. Defaults to false.
#
# @param override_options Custom MySQL variable overrides. Defaults to an empty hash.
#
# @param access_mysql_from Array of IP addresses allowed to access MySQL. Defaults to ['0.0.0.0/0'].
#
# @groups authentication root_password, local_tcp_root_access
#
# @groups data_configuration datadir, memlimit, override_options
#
# @groups binlog_configuration binlog
#
# @groups access_control access_mysql_from, mysql_restart_on_config_change
#
# @groups backup_configuration backup
#
class role::db::mysql (
  Eit_types::MysqlPassword              $root_password,
  String                                $datadir                        = '/var/lib/mysql',
  Eit_types::Percentage                 $memlimit                       = 75,
  Boolean                               $mysql_restart_on_config_change = false,
  Boolean                               $backup                         = true,
  Boolean                               $binlog                         = true,
  Boolean                               $local_tcp_root_access          = false,
  Hash[Eit_types::Mysql_Variable, Data] $override_options               = {},
  Array[Stdlib::IP::Address]            $access_mysql_from              = ['0.0.0.0/0'],
) inherits ::role::db {

  # contained before the confines and the profile below, which read its parameters
  contain role::db::mysql::binlog

  confine($binlog, !$role::db::mysql::binlog::max_size_bytes, '`binlog_max_size_bytes` is needed for `binlog`')
  confine($binlog, $role::db::mysql::binlog::sync == undef, '`binlog_sync` is needed for `binlog`')
  confine($binlog, $role::db::mysql::binlog::backup_interval, !$role::db::mysql::binlog::backup_target, '`binlog_sync_target` must be set if `binlog_sync_interval` is defined')
  confine($binlog, !$role::db::mysql::binlog::backup_interval, $role::db::mysql::binlog::backup_target, '`binlog_sync_interval` must be set if `binlog_sync_target` is defined')

  #we only handle backup if they are on lvm disks for now -
  #FIXME : handle mysql on /root - using regular mysqldump at night
  #FIXME: confirm that mysqld_datadir_on_root actually checks that the datadir IS an lvm device !
  class { '::profile::db::mysql':
    datadir                        => $datadir,
    backup                         => $backup,
    root_password                  => $root_password,
    innodb_buffer_percentage       => $memlimit,
    mysql_restart_on_config_change => $mysql_restart_on_config_change,
    local_tcp_root_access          => $local_tcp_root_access,
    binlog                         => $binlog,
    binlog_format                  => $role::db::mysql::binlog::format,
    binlog_dir                     => $role::db::mysql::binlog::dir,
    binlog_max_size_bytes          => $role::db::mysql::binlog::max_size_bytes,
    binlog_sync                    => $role::db::mysql::binlog::sync,
    override_options               => $override_options,
    access_mysql_from              => $access_mysql_from,
  }

  # FIXME: binlog backup not implemented
  if $role::db::mysql::binlog::backup_target {
    @@commmon::backup::pull::backup { "pull mysql binlog from ${facts['networking']['fqdn']}":
      from        => $facts['networking']['fqdn'],
      to          => $role::db::mysql::binlog::backup_target,
      source      => 1,
      destination => $role::db::mysql::binlog::backup_target_dir,
    }
  }
}
