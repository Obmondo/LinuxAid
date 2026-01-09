# @summary Class for managing MySQL backup configuration and override for common::backup::db settings
#
# @param enable Whether to enable the MySQL backup. Defaults to the value of $::common::backup::db::enable.
#
# @param backup_user_password The password for the backup user. Defaults to $::common::backup::db::backup_user_password.
#
# @param backup_hour The hour of backup. Defaults to $::common::backup::db::backup_hour.
#
# @param ignore_tables List of tables to ignore during backup. Defaults to $::common::backup::db::ignore_tables.
#
# @param backup_user The user to perform backup with. Defaults to $::common::backup::db::backup_user.
#
# @param dump_dir Directory for dump files. Defaults to $::common::backup::db::dump_dir.
#
# @param backup_retention Number of days to retain backups. Defaults to $::common::backup::db::backup_retention.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups credentials backup_user, backup_user_password, encrypt_params
#
# @groups schedule backup_hour
#
# @groups configuration enable, backup_retention, ignore_tables, dump_dir
#
# @encrypt_params backup_user_password
#
class common::backup::db::mysql::mysqlbackup (
  Boolean                   $enable                = $::common::backup::db::enable,
  Eit_types::Password       $backup_user_password  = $::common::backup::db::backup_user_password,
  Integer[0,23]             $backup_hour           = $::common::backup::db::backup_hour,
  Array[String]             $ignore_tables         = $::common::backup::db::ignore_tables,
  Eit_types::User           $backup_user           = $::common::backup::db::backup_user,
  Stdlib::Absolutepath      $dump_dir              = $::common::backup::db::dump_dir,
  Eit_types::Duration::Days $backup_retention      = $::common::backup::db::backup_retention,
  Eit_types::Encrypt::Params $encrypt_params       = ['backup_user_password'],
) inherits ::common::backup::db {

  $_ignore_tables = $ignore_tables.map |$table| {
    # https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#option_mysqldump_ignore-table
    "--ignore-table=${table}"
  }.delete_undef_values

  class { 'mysql::server::backup' :
    provider           => 'mysqlbackup',
    backupuser         => $backup_user,
    backuppassword     => $backup_user_password,
    backupdir          => $dump_dir,
    backupcompress     => true,
    backuprotate       => $backup_retention,
    backupmethod       => 'mysqldump',
    delete_before_dump => false,
    include_routines   => true,
    include_triggers   => true,
    time               => [$backup_hour, 3], # (i.e., 03:45) for HH:MM
    optional_args      => $_ignore_tables,
    install_cron       => false,
  }
}
