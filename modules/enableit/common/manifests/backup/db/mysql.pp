# @summary Class for managing MySQL backup settings with specific overrides
#
# @param backup_user_password The password for the backup user. Defaults to $::common::backup::db::backup_user_password.
#
# @param enable Whether to enable backup. Defaults to $::common::backup::db::enable.
#
# @param backup_hour The hour of the day to perform backup. Defaults to $::common::backup::db::backup_hour.
#
# @param ignore_tables List of tables to ignore during backup. Defaults to $::common::backup::db::ignore_tables.
#
# @param backup_method The backup method to use ('xtrabackup', 'mysqldump', 'mysqlbackup'). Defaults to $::common::backup::db::backup_method.
#
# @param backup_user The user for backup operations. Defaults to $::common::backup::db::backup_user.
#
# @param dump_dir The directory to store backups. Defaults to $::common::backup::db::dump_dir.
#
# @param backup_retention Duration to retain backups. Defaults to $::common::backup::db::backup_retention.
#
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
