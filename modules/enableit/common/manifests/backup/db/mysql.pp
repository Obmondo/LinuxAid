# @summary Class for managing MySQL backup settings with specific overrides
#
# @param backup_user_password The password for the backup user. Defaults to $::common::backup::db::backup_user_password.
#
# @param backup_method The backup method to use ('xtrabackup', 'mysqldump', 'mysqlbackup'). Defaults to $common::backup::db::backup_method.
#
# @param host The database host. Defaults to 'localhost'.
#
# @param root_password The root password for the database. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @encrypt_params backup_user_password, root_password
#
# @groups general encrypt_params
#
# @groups authentication backup_user_password, root_password, host
#
# @groups backup_config backup_method
#
class common::backup::db::mysql (
  Eit_types::Password        $backup_user_password  = $::common::backup::db::backup_user_password,
  Enum[
    'xtrabackup',
    'mysqldump',
    'mysqlbackup'
  ]                          $backup_method         = $::common::backup::db::backup_method,
  Eit_types::Encrypt::Params $encrypt_params        = ['backup_user_password'],
  Optional[Eit_types::Host]  $host                  = 'localhost',

  Optional[Eit_types::Password] $root_password = undef,

) inherits ::common::backup::db {
  contain "common::backup::db::mysql::${backup_method}"

  # Since the mysql module only support backup from localhost.
  # For taking backup from different host we are using our own script.
  if $host != 'localhost' {
    $_backup_hour = $::common::backup::db::backup_hour

    file {'/opt/obmondo/bin/mysqlbackup.sh':
      ensure  => ensure_present($::common::backup::db::enable),
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      content => epp('common/backup/mysqlbackup.sh.epp', {
        backup_user          => $::common::backup::db::backup_user,
        backup_user_password => $backup_user_password,
        host                 => $host,
        root_password        => $root_password,
        backup_retention     => $::common::backup::db::backup_retention,
        dump_dir             => $::common::backup::db::dump_dir,
      }),
    }
    # Define the MySQL Backup Service
    $_mysql_service_content = @("EOT"/)
      [Unit]
      Description=MySQL Backup Service
      Wants=mysql-backup.timer

      [Service]
      Type=oneshot
      ExecStart=/bin/sh -c '/opt/obmondo/bin/mysqlbackup.sh'

      [Install]
      WantedBy=multi-user.target
      | EOT

    systemd::unit_file { 'mysql-backup.service':
      ensure  => 'present',
      content => $_mysql_service_content,
      require => File['/opt/obmondo/bin/mysqlbackup.sh'],
    }

    # Define the MySQL Backup Timer
    $_mysql_timer_content = @("EOT"/)
      [Unit]
      Description=Run MySQL Backup daily at ${_backup_hour}:00
      Requires=mysql-backup.service

      [Timer]
      OnCalendar=*-*-* ${_backup_hour}:00:00
      Unit=mysql-backup.service

      [Install]
      WantedBy=timers.target
      | EOT

    systemd::unit_file { 'mysql-backup.timer':
      ensure  => 'present',
      enable  => true,
      active  => true,
      content => $_mysql_timer_content,
      require => [
        File['/opt/obmondo/bin/mysqlbackup.sh'],
        Systemd::Unit_file['mysql-backup.service'],
      ],
    }
  }
}
