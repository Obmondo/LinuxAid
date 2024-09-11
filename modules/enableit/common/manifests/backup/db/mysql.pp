#
# Specific settings for mysql and override for common::backup::db settings
#
# Backup Strategy.
# xtrabackup creates everyday backup to desired dump_dir (/backup) and
# borg backup push the /backup tp borg servers
class common::backup::db::mysql (
  Eit_types::Password       $backup_user_password  = $::common::backup::db::backup_user_password,
  Boolean                   $enable                = $::common::backup::db::enable,
  Integer[0,23]             $backup_hour           = $::common::backup::db::backup_hour,
  Array[String]             $ignore_tables         = $::common::backup::db::ignore_tables,
  Enum[
    'xtrabackup',
    'mysqldump',
    'mysqlbackup'
  ]                         $backup_method         = $::common::backup::db::backup_method,
  Eit_types::SimpleString   $backup_user           = $::common::backup::db::backup_user,
  Stdlib::Absolutepath      $dump_dir              = $::common::backup::db::dump_dir,
  Eit_types::Duration::Days $backup_retention      = $::common::backup::db::backup_retention,
) inherits ::common::backup::db {

  contain "common::backup::db::mysql::${backup_method}"
}
