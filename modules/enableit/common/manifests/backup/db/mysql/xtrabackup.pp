# @summary Class for managing MySQL backup using xtrabackup and Borg
#
# @param backup_user_password The password for the backup user. Defaults to the value of ::common::backup::db::backup_user_password.
#
# @param enable Enable or disable the backup. Defaults to the value of ::common::backup::db::enable.
#
# @param backup_hour The hour of day to run the backup (0-23). Defaults to the value of ::common::backup::db::backup_hour.
#
# @param ignore_tables List of tables to ignore during backup. Defaults to the value of ::common::backup::db::ignore_tables.
#
# @param backup_user The backup database user. Defaults to the value of ::common::backup::db::backup_user.
#
# @param dump_dir Directory where backups are stored. Defaults to the value of ::common::backup::db::dump_dir.
#
# @param backup_retention Duration (in days) to retain backups. Defaults to the value of ::common::backup::db::backup_retention.
#
class common::backup::db::mysql::xtrabackup (
  Eit_types::Password       $backup_user_password  = $::common::backup::db::backup_user_password,
  Boolean                   $enable                = $::common::backup::db::enable,
  Integer[0,23]             $backup_hour           = $::common::backup::db::backup_hour,
  Array[String]             $ignore_tables         = $::common::backup::db::ignore_tables,
  Eit_types::SimpleString   $backup_user           = $::common::backup::db::backup_user,
  Stdlib::Absolutepath      $dump_dir              = $::common::backup::db::dump_dir,
  Eit_types::Duration::Days $backup_retention      = $::common::backup::db::backup_retention,
) inherits ::common::backup::db {

  # To support multiple borg repos, we need to see if the dump_dir and the borg archive is same.
  # if it is, then we assume that the borg repo is correct for this particular backup.
  if ! lookup('common::backup::borg::repos', Hash, undef, {}).empty {
    $last_borgbackup = $::common::backup::borg::last_borgbackup
    $repo_name = lookup('common::backup::borg::repos').map |$key, $value| {
      if $dump_dir in $value['archives'] {
        $key
      }
    }.delete_undef_values.unique.sort.join(', ')
    $_last_borgbackup = "${last_borgbackup}/borg_last_backup_${repo_name}"
  } else {
    $_last_borgbackup = undef
  }
  # FIXME: also move more the rest of backup settings from role::db::mysql -
  # so role's don't have backup settings directly
  $_privs = [
    'RELOAD',
    'PROCESS',
    'LOCK TABLES',
    'REPLICATION CLIENT',
  ]
  class { '::xtrabackup':
    backup_dir       => $dump_dir,
    mysql_user       => $backup_user,
    mysql_pass       => $backup_user_password,
    backup_retention => $backup_retention,
    cron_hour        => $backup_hour,
    last_borgbackup  => $_last_borgbackup,
  }
  $_fq_backup_user = "${backup_user}@localhost"
  mysql_user { $_fq_backup_user:
    ensure        => present,
    password_hash => mysql_password($backup_user_password),
    require       => Class['mysql::server::service'],
  }
  mysql_grant { "${_fq_backup_user}/*.*":
    ensure     => present,
    options    => ['GRANT'],
    privileges => $_privs,
    table      => '*.*',
    user       => $_fq_backup_user,
    require    => Mysql_user[$_fq_backup_user],
  }
  $env = {
    'MYSQL_IGNORE_TABLES' => $ignore_tables,
    'MYSQL_BACKUP_USER'   => $backup_user,
  }
  $env_file = "${common::setup::__conf_dir}/mysql/backup.env"
  file { $env_file:
    ensure  => file,
    content => hash_to_ini($env, {
      quote      => '"',
      escape     => false,
      skip_undef => true,
    }),
  }
  ['mysql', 'mysqldump'].each |$section| {
    ini_setting {
      default:
        ensure            => present,
        section           => $section,
        path              => '/root/.my.backup.cnf',
        key_val_separator => '=',
        show_diff         => false,
        ;

        "my.cnf ${section} backup user":
          setting => 'user',
          value   => "'${backup_user}'",
        ;

        "my.cnf ${section} backup password":
          setting => 'password',
          value   => "'${backup_user_password}'",
        ;
    }
  }
}
