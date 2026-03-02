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
# @param backup_method The backup method to use ('xtrabackup', 'mysqldump', 'mysqlbackup'). Defaults to $common::backup::db::backup_method.
#
# @param backup_user The user for backup operations. Defaults to $::common::backup::db::backup_user.
#
# @param dump_dir The directory to store backups. Defaults to $::common::backup::db::dump_dir.
#
# @param backup_retention Duration to retain backups. Defaults to $::common::backup::db::backup_retention.
#
# @param host The database host. Defaults to 'localhost'.
#
# @param root_password The root password for the database. Defaults to $::common::backup::root_password.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @encrypt_params backup_user_password, root_password
#
# @groups general enable, encrypt_params
#
# @groups authentication backup_user, backup_user_password, root_password, host
#
# @groups schedule backup_hour
#
# @groups storage dump_dir
#
# @groups retention backup_retention, ignore_tables
#
# @groups backup_config backup_method
#
class common::backup::db::mysql (
  Eit_types::Password        $backup_user_password  = $::common::backup::db::backup_user_password,
  Boolean                    $enable                = $::common::backup::db::enable,
  Integer[0,23]              $backup_hour           = $::common::backup::db::backup_hour,
  Array[String]              $ignore_tables         = $::common::backup::db::ignore_tables,
  Enum[
    'xtrabackup',
    'mysqldump',
    'mysqlbackup'
  ]                          $backup_method         = $::common::backup::db::backup_method,
  Eit_types::SimpleString    $backup_user           = $::common::backup::db::backup_user,
  Stdlib::Absolutepath       $dump_dir              = $::common::backup::db::dump_dir,
  Eit_types::Duration::Days  $backup_retention      = $::common::backup::db::backup_retention,
  Eit_types::Encrypt::Params $encrypt_params        = ['backup_user_password'],
  Optional[Eit_types::Host]  $host                  = 'localhost',

  Optional[Eit_types::Password] $root_password = $::common::backup::root_password,

) inherits ::common::backup::db {
  contain "common::backup::db::mysql::${backup_method}"

  # Since the mysql module only support backup from localhost.
  # For taking backup from different host we are using our own script.
  if $host != 'localhost' {
    file {'/opt/obmondo/bin/mysqlbackup.sh':
      ensure  => ensure_present($enable),
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => epp('common/backup/mysqlbackup.sh.epp', {
        backup_user          => $backup_user,
        backup_user_password => $backup_user_password,
        host                 => $host,
        root_password        => $root_password,
        backup_retention     => $backup_retention,
        dump_dir             => $dump_dir,
      }),
    }
    common::services::systemd { 'mysql-backup.timer':
      ensure  => true,
      enable  => true,
      timer   => {
        'OnCalendar' => systemd_make_timespec({
          'year'   => '*',
          'month'  => '*',
          'day'    => '*',
          'hour'   => $backup_hour,
          'minute' => 0,
          'second' => 0,
        }),
        'Unit'       => 'mysql-backup.service',
      },
      unit    => {
        'Requires'  => 'mysql-backup.service',
      },
      install => {
        'WantedBy' => 'timers.target',
      },
      require => File['/opt/obmondo/bin/mysqlbackup.sh'],
    }
    common::services::systemd { 'mysql-backup.service':
      ensure  => 'present',
      unit    => {
        'Wants'    => 'mysql-backup.timer',
      },
      service => {
        'Type'      => 'oneshot',
        'ExecStart' => "/bin/sh -c '/opt/obmondo/bin/mysqlbackup.sh'",
      },
      require => File['/opt/obmondo/bin/mysqlbackup.sh'],
    }
  }
}
