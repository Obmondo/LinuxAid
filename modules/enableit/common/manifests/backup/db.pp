# @summary Class for managing common backup settings for databases
#
# @param enable Boolean flag to enable or disable backup. Defaults to the value of $::common::backup::enable.
#
# @param backup_user_password Optional password for backup user. Defaults to the value of $::common::backup::backup_user_password.
#
# @param backup_user The username for backup. Defaults to the value of $::common::backup::backup_user.
#
# @param dump_dir Filesystem path for dump directory. Defaults to the value of $::common::backup::dump_dir.
#
# @param backup_retention Number of days to retain backups. Defaults to 30.
#
# @param backup_hour Hour of the day to start backup (local server time). Defaults to 3.
#
# @param ignore_tables Array of table names to ignore during backup. Defaults to [].
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups authentication backup_user_password, backup_user.
#
# @groups files_and_directories dump_dir.
#
# @groups retention backup_retention, ignore_tables.
#
# @groups schedule backup_hour.
#
# @groups general enable, encrypt_params.
#
# @encrypt_params backup_user_password.
#
class common::backup::db (
  Boolean                       $enable               = $::common::backup::enable,
  Optional[Eit_types::Password] $backup_user_password = $::common::backup::backup_user_password,
  String                        $backup_user          = $::common::backup::backup_user,
  Stdlib::Unixpath              $dump_dir             = $::common::backup::dump_dir,
  Eit_types::Duration::Days     $backup_retention     = 30,
  Integer[0,23]                 $backup_hour          = 3,
  Array[String]                 $ignore_tables        = [],
  Eit_types::Encrypt::Params    $encrypt_params       = ['backup_user_password'],
) inherits ::common::backup {
  confine($enable, !$::common::backup::dump_dir, '`common::backup::dump_dir` needs to be set')
}
