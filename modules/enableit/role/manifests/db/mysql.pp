# Mysql Role
class role::db::mysql (
  Eit_types::MysqlPassword              $root_password,
  Boolean                               $webadmin                       = true,
  String                                $datadir                        = '/var/lib/mysql',
  Eit_types::Percentage                 $memlimit                       = 75,
  Boolean                               $mysql_restart_on_config_change = false,
  Boolean                               $backup                         = true,
  Boolean                               $binlog                         = true,
  Enum['MIXED', 'ROW', 'STATEMENT']     $binlog_format                  = 'MIXED',
  Boolean                               $local_tcp_root_access          = false,
  Optional[Stdlib::Absolutepath]        $binlog_dir                     = "${datadir}/binlog/${facts['fqdn']}",
  Optional[Integer[4096, 1073741824]]   $binlog_max_size_bytes          = 1*1024*1024*1024, # 1 GB
  Optional[Integer[0, 4294967295]]      $binlog_sync                    = 1,
  Optional[Eit_types::CustomerHost]     $binlog_backup_target           = undef,
  Optional[Stdlib::Absolutepath]        $binlog_backup_target_dir       = undef,
  Optional[Eit_types::TimeSpan]         $binlog_backup_interval         = undef,
  Hash[Eit_types::Mysql_Variable, Data] $override_options               = {},
  Array[Stdlib::IP::Address]            $access_mysql_from              = ['0.0.0.0/0'],
) inherits ::role::db {

  confine($binlog, !$binlog_max_size_bytes, '`binlog_max_size_bytes` is needed for `binlog`')
  confine($binlog, $binlog_sync == undef, '`binlog_sync` is needed for `binlog`')
  confine($binlog, $binlog_backup_interval, !$binlog_backup_target, '`binlog_sync_target` must be set if `binlog_sync_interval` is defined')
  confine($binlog, !$binlog_backup_interval, $binlog_backup_target, '`binlog_sync_interval` must be set if `binlog_sync_target` is defined')

  #we only handle backup if they are on lvm disks for now -
  #FIXME : handle mysql on /root - using regular mysqldump at night
  #FIXME: confirm that mysqld_datadir_on_root actually checks that the datadir IS an lvm device !

  class { '::profile::mysql':
    webadmin                       => $webadmin,
    datadir                        => $datadir,
    backup                         => $backup,
    root_password                  => $root_password,
    innodb_buffer_percentage       => $memlimit,
    mysql_restart_on_config_change => $mysql_restart_on_config_change,
    local_tcp_root_access          => $local_tcp_root_access,
    binlog                         => $binlog,
    binlog_dir                     => $binlog_dir,
    binlog_max_size_bytes          => $binlog_max_size_bytes,
    binlog_sync                    => $binlog_sync,
    override_options               => $override_options,
    access_mysql_from              => $access_mysql_from,
  }

  # FIXME: binlog backup not implemented

  if $binlog_backup_target {
    @@commmon::backup::pull::backup { "pull mysql binlog from ${facts['fqdn']}":
      from        => $facts['fqdn'],
      to          => $binlog_backup_target,
      source      => 1,
      destination => $binlog_backup_target_dir,
    }
  }
}
