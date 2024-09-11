#
# Specific settings for postgresql and override for common::backup::db settings
#
class common::backup::db::pgsql (
  Boolean                    $enable           = $common::backup::db::enable,
  Integer[0,23]              $backup_hour      = $common::backup::db::backup_hour,
  Eit_types::SimpleString    $backup_user      = $common::backup::db::backup_user,
  Array[String]              $ignore_tables    = $common::backup::db::ignore_tables,
  Optional[Stdlib::Unixpath] $dump_dir         = $common::backup::db::dump_dir,
  Eit_types::Duration::Days  $backup_retention = $common::backup::db::backup_retention,
) inherits common::backup::db {

  confine($enable, !$dump_dir,
          '`$dump_dir` must be set if backup is enabled')

  # TODO: We should check more assumptions - like if we have write access to
  # backup target location.. or perhaps just fix it ?

  $ensure = $enable ? {
    true  => 'present',
    false => 'absent'
  }

  $backup_script = '/usr/local/sbin/pgsql-dump-backup.sh'

  if $enable {
    file { $dump_dir:
      ensure => directory,
      owner  => $backup_user,
      mode   => '0755',
    }

    file { "${common::setup::__conf_dir}/pgsql":
      ensure => directory,
    }

  }

  file { $backup_script:
    ensure => $ensure,
    source => 'puppet:///modules/profile/postgresql/pg-dump-backup.sh',
    mode   => '0555',
  }

  # NOTE: `ignore_tables` is handled by the script
  # backup user is `postgres` since that is the default user.
  cron::daily { 'backup_pgsql':
    ensure  => $ensure,
    minute  => fqdn_rand(60),
    hour    => $backup_hour,
    user    => $backup_user,
    command => $backup_script,
    require => File[$backup_script],
  }

  package::install([
    'bc',
    'xz',
  ])

  $env = {
    'KEEP_DAYS'           => $backup_retention,
    'BACKUP_DIR'          => $dump_dir,
    'PGSQL_IGNORE_TABLES' => $ignore_tables,
  }

  $env_file = "${common::setup::__conf_dir}/pgsql/backup.env"

  functions::create_ini_file($env_file, $env, {
    ensure => $enable ? {
      true    => present,
      default => absent,
    },
  })
}
