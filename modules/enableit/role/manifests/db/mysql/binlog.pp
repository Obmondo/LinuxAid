# @summary Binary log settings for MySQL, used when `binlog` is enabled
#
# @param format The binary log format. Defaults to 'MIXED'.
#
# @param dir The directory the binary logs are written to. Defaults to a per-host directory under the datadir.
#
# @param max_size_bytes The maximum size of a binary log file. Defaults to 1 GB.
#
# @param sync How often the binary log is synced to disk. Defaults to 1.
#
# @param backup_target The host the binary logs are pulled to. Defaults to undef.
#
# @param backup_target_dir The directory on the target the binary logs are pulled to. Defaults to undef.
#
# @param backup_interval How often the binary logs are pulled. Defaults to undef.
#
# @groups binlog format, dir, max_size_bytes, sync, backup_target, backup_target_dir, backup_interval
#
class role::db::mysql::binlog (
  Enum['MIXED', 'ROW', 'STATEMENT']   $format            = 'MIXED',
  Optional[Stdlib::Absolutepath]      $dir               = "${role::db::mysql::datadir}/binlog/${facts['networking']['fqdn']}",
  Optional[Integer[4096, 1073741824]] $max_size_bytes    = 1*1024*1024*1024, # 1 GB
  Optional[Integer[0, 4294967295]]    $sync              = 1,
  Optional[Eit_types::CustomerHost]   $backup_target     = undef,
  Optional[Stdlib::Absolutepath]      $backup_target_dir = undef,
  Optional[Eit_types::TimeSpan]       $backup_interval   = undef,
) {
}
