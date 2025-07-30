# @summary Class for managing common backup settings for databases
#
# @param enable Boolean flag to enable or disable backup. Defaults to the value of $::common::backup::enable.
#
# @param backup_user_password Optional password for backup user. Defaults to the value of $::common::backup::backup_user_password.
#
# @param backup_user The username for backup. Defaults to the value of $::common::backup::backup_user.
#
# @param root_password Optional password for root user. Defaults to the value of $::common::backup::root_password.
#
# @param dump_dir Filesystem path for dump directory. Defaults to the value of $::common::backup::dump_dir.
#
# @param backup_retention Number of days to retain backups. Defaults to 30.
#
# @param backup_hour Hour of the day to start backup (local server time). Defaults to 3.
#
# @param ignore_tables Array of table names to ignore during backup. Defaults to [].
#
# @param host Hostname for database. Defaults to 'localhost'.
#
# @param backup_method Backup method to use ('mysqldump', 'mysqlbackup', 'xtrabackup'). Defaults to 'mysqldump'.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class common::backup::db (
  Boolean                       $enable                = $::common::backup::enable,
  Optional[Eit_types::Password] $backup_user_password  = $::common::backup::backup_user_password,
  String                        $backup_user           = $::common::backup::backup_user,
  Optional[Eit_types::Password] $root_password         = $::common::backup::root_password,
  Stdlib::Unixpath              $dump_dir              = $::common::backup::dump_dir,
  Eit_types::Duration::Days     $backup_retention      = 30,
  Integer[0,23]                 $backup_hour           = 3,
  Array[String]                 $ignore_tables         = [],
  Optional[Eit_types::Host]       $host                  = 'localhost',
  Enum['mysqldump', 'mysqlbackup', 'xtrabackup'] $backup_method = 'mysqldump',
  Eit_types::Encrypt::Params $encrypt_params           = ['root_password','backup_user_password'],
) inherits ::common::backup {
  confine($enable, !$::common::backup::dump_dir, '`common::backup::dump_dir` needs to be set')
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
