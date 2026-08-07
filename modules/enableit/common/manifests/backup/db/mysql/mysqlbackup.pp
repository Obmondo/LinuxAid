# @summary Class for managing MySQL backup configuration and override for common::backup::db settings
#
# @param backup_user_password The password for the backup user. Defaults to $::common::backup::db::backup_user_password.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @encrypt_params backup_user_password
#
# @groups authentication backup_user_password, encrypt_params
#
class common::backup::db::mysql::mysqlbackup (
  Eit_types::Password        $backup_user_password = $::common::backup::db::backup_user_password,
  Eit_types::Encrypt::Params $encrypt_params       = ['backup_user_password'],
) inherits ::common::backup::db {

  $_ignore_tables = $::common::backup::db::ignore_tables.map |$table| {
    # https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html#option_mysqldump_ignore-table
    "--ignore-table=${table}"
  }.delete_undef_values

  class { 'mysql::server::backup' :
    provider           => 'mysqlbackup',
    backupuser         => $::common::backup::db::backup_user,
    backuppassword     => $backup_user_password,
    backupdir          => $::common::backup::db::dump_dir,
    backupcompress     => true,
    backuprotate       => $::common::backup::db::backup_retention,
    backupmethod       => 'mysqldump',
    delete_before_dump => false,
    include_routines   => true,
    include_triggers   => true,
    time               => [$::common::backup::db::backup_hour, 3], # (i.e., 03:45) for HH:MM
    optional_args      => $_ignore_tables,
    install_cron       => false,
  }
}
