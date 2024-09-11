#
# Contains common settings for Backup of DB's
#
class common::backup::db (
  Boolean                       $enable                = $::common::backup::enable,
  Optional[Eit_types::Password] $backup_user_password  = $::common::backup::backup_user_password,
  Eit_types::SimpleString       $backup_user           = $::common::backup::backup_user,
  Optional[Eit_types::Password] $root_password         = $::common::backup::root_password,
  Stdlib::Unixpath              $dump_dir              = $::common::backup::dump_dir,
  Eit_types::Duration::Days     $backup_retention      = 30,
  Integer[0,23]                 $backup_hour           = 3, # what hour to start backup; time is in server local time
  Array[String]                 $ignore_tables         = [],
  Optional[Eit_types::Host]     $host                  = 'localhost',
  Enum[
    'mysqldump',
    'mysqlbackup',
    'xtrabackup'
  ]                             $backup_method         = 'mysqldump',
  Optional[String]              $backup_databases      = undef,
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
