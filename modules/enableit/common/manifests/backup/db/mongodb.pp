# @summary Class for managing MongoDB backups
#
# @param enable Boolean to enable or disable the backup feature. Defaults to the value of $::common::backup::db::enable.
#
# @param backup_user The user used for the backup process. Defaults to the value of $::common::backup::db::backup_user.
#
# @param backup_user_password The password for the backup user. Defaults to the value of $::common::backup::db::backup_user_password.
#
# @param backup_hour The hour of the day (0-23) when the backup should run. Defaults to the value of $::common::backup::db::backup_hour.
#
# @param backup_method The method of backup, either 'snapshot' or 'dump'. Defaults to the value of $::common::backup::db::backup_method.
#
# @param dump_dir The directory where backups will be stored. Defaults to the value of $::common::backup::db::dump_dir.
#
# @param backup_databases Optional list of databases to backup. Defaults to the value of $::common::backup::db::backup_databases.
#
# @param backup_retention Duration to retain backups in days. Defaults to the value of $::common::backup::db::backup_retention.
#
class common::backup::db::mongodb (
  Boolean                   $enable                = $::common::backup::db::enable,
  Eit_types::User           $backup_user           = $::common::backup::db::backup_user,
  Eit_types::Password       $backup_user_password  = $::common::backup::db::backup_user_password,
  Integer[0,23]             $backup_hour           = $::common::backup::db::backup_hour,
  Enum[
    'snapshot',
    'dump'
  ]                         $backup_method         = $::common::backup::db::backup_method,
  Stdlib::Absolutepath      $dump_dir              = $::common::backup::db::dump_dir,
  Optional[String]          $backup_databases      = $::common::backup::db::backup_databases,
  Eit_types::Duration::Days $backup_retention      = $::common::backup::db::backup_retention,
) inherits ::common::backup::db {

  package::install ( 'obmondo-scripts-backup-mongodb' )

  $env = {
    'MONGO_HOST'       => '127.0.0.1',
    'MONGO_PORT'       => '27017',
    'MONGO_DATABASE'   => $backup_databases,
    'BACKUP_DIR'       => $dump_dir,
    'DBUSERNAME'       => $backup_user,
    'DBPASSWORD'       => $backup_user_password,
    'DBAUTHDB'         => 'admin',
    'BACKUP_RETENTION' => $backup_retention,
    'LOGFILE'          => '/var/log/mongodb/mongodump.log',
    'PRUNE_BACKUPS'    => true,
  }

  $env_dir  = "${common::setup::__conf_dir}/mongodb"
  $env_file = "${env_dir}/backup.env"

  file { $env_dir:
    ensure => ensure_dir($enable),
  }

  file { $env_file:
    ensure  => file,
    content => hash_to_ini($env, {
      quote      => '"',
      escape     => false,
      skip_undef => true,
    }),
    require => File[$env_dir],
  }

  cron { 'MongoDB Backup':
    ensure  => ensure_present($enable),
    user    => root,
    command => '/opt/obmondo/bin/mongodb_backup.sh',
    hour    => $backup_hour,
    minute  => 0,
  }

  mongodb_user { 'obmondo-backup':
    ensure        => present,
    database      => 'admin',
    password_hash => mongodb_password($backup_user, $backup_user_password),
    roles         => ['backup'],
    require       => Class['mongodb::server'],
  }
}
