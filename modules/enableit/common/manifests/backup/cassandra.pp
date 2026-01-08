# @summary Backup Cassandra database using medusa with local storage
#
# @param enable Enable backup
# @param cassandra_user User to run Cassandra
# @param backup_hour Backup hour for backups
# @param snapshot_name Snapshot name
# @param medusa_bucket_name Bucket name (directory name for local storage)
# @param medusa_base_path Base path for local storage backups
# @param cassandra_config_file Path to Cassandra configuration file
# @param max_backup_count Maximum number of backups to retain (0 = unlimited)
# @param max_backup_age Maximum age of backups in days (0 = unlimited)
# @param enable_cleanup Enable automatic cleanup of old backups using Medusa purge
# @param cleanup_hour Hour to run cleanup (should be different from backup_hour)
#
# @groups schedule backup_hour, cleanup_hour.
#
# @groups cleanup enable_cleanup, max_backup_count, max_backup_age.
#
# @groups storage medusa_bucket_name, medusa_base_path.
#
# @groups user cassandra_user.
#
# @groups config cassandra_config_file.
#
# @groups snapshot snapshot_name.
#
# @groups enable enable.
#
class common::backup::cassandra (
  Boolean          $enable                = false,
  String           $cassandra_user        = 'cassandra',
  Integer[0,23]    $backup_hour           = 0,
  String           $snapshot_name         = 'cassandra_snapshot',
  String           $medusa_bucket_name    = 'cassandra_backups',
  Stdlib::Unixpath $medusa_base_path      = '/var/lib/medusa/backups',
  Stdlib::Unixpath $cassandra_config_file = '/etc/cassandra/default.conf/cassandra.yaml',
  Integer          $max_backup_count      = 10,
  Integer          $max_backup_age        = 30,
  Boolean          $enable_cleanup        = true,
  Integer[0,23]    $cleanup_hour          = 1,
) {
  $medusa_parent_dir = dirname($medusa_base_path)

  file {
    default:
      ensure => directory,
      mode   => '0755',
      owner  => $cassandra_user,
      group  => $cassandra_user,
      ;

    $medusa_parent_dir:
      ;

    $medusa_base_path:
      require => File[$medusa_parent_dir],
      ;

    '/etc/medusa':
      owner => 'root',
      group => 'root',
      ;
  }

  class { 'python':
    ensure   => present,
    version  => '3',
    pip      => present,
    dev      => present,
    use_epel => false,
  }

  python::pyvenv { '/opt/medusa':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Class['python'],
  }

  python::pip { 'cassandra-medusa':
    ensure       => present,
    virtualenv   => '/opt/medusa',
    pip_provider => 'pip3',
    owner        => 'root',
    timeout      => 900,
    require      => Python::Pyvenv['/opt/medusa'],
  }

  file { '/etc/medusa/medusa.ini':
    ensure  => ensure_present($enable),
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    content => epp('common/backup/medusa.ini.epp', {
      'cassandra_config_file' => $cassandra_config_file,
      'cql_username'          => '',
      'cql_password'          => '',
      'cql_host'              => '127.0.0.1',
      'cql_port'              => 9042,
      'storage_provider'      => 'local',
      'bucket_name'           => $medusa_bucket_name,
      'base_path'             => $medusa_base_path,
      'max_backup_count'      => $max_backup_count,
      'max_backup_age'        => $max_backup_age,
      'monitoring_provider'   => 'local',
      'ssh_username'          => '',
      'ssh_key_file'          => '',
      'ssh_port'              => 22,
      'ssh_cert_file'         => '',
      'health_check'          => '',
      'query'                 => '',
      'stop_cmd'              => '',
      'start_cmd'             => '',
      'log_level'             => 'INFO',
    }),
    require => [Python::Pip['cassandra-medusa'], File['/etc/medusa']]
  }

  systemd::manage_unit { 'cassandra-backup.timer':
    ensure        => 'present',
    enable        => true,
    active        => true,
    unit_entry    => {
      'Description' => 'Cassandra Backup Timer',
      'Requires'    => 'cassandra-backup.service',
    },
    timer_entry   => {
      'OnCalendar' => "*-*-* ${backup_hour}:00:00",
      'Unit'       => 'cassandra-backup.service',
    },
    install_entry => {
      'WantedBy' => 'timers.target',
    },
    require       => File['/etc/medusa/medusa.ini'],
  }

  systemd::manage_unit { 'cassandra-backup.service':
    ensure        => 'present',
    enable        => true,
    unit_entry    => {
      'Description' => 'Cassandra Backup Service',
      'Wants'       => 'cassandra-backup.timer',
    },
    service_entry => {
      'Type'      => 'oneshot',
      'ExecStart' => "/bin/bash -c '/opt/medusa/bin/medusa backup --backup-name=${snapshot_name}_$(date +%%Y%%m%%d_%%H%%M%%S) --mode=full'",
    },
    install_entry => {
      'WantedBy' => 'multi-user.target',
    },
    require       => File['/etc/medusa/medusa.ini'],
  }

  if $enable_cleanup {
    systemd::manage_unit { 'cassandra-backup-cleanup.timer':
      ensure        => ensure_present($enable),
      enable        => true,
      active        => true,
      unit_entry    => {
        'Description' => 'Cassandra Backup Cleanup Timer',
        'Requires'    => 'cassandra-backup-cleanup.service',
      },
      timer_entry   => {
        'OnCalendar' => "*-*-* ${cleanup_hour}:00:00",
        'Unit'       => 'cassandra-backup-cleanup.service',
      },
      install_entry => {
        'WantedBy' => 'timers.target',
      },
      require       => Systemd::Manage_unit['cassandra-backup.service'],
    }

    systemd::manage_unit { 'cassandra-backup-cleanup.service':
      ensure        => ensure_present($enable),
      enable        => true,
      unit_entry    => {
        'Description' => 'Cassandra Backup Cleanup Service (Medusa Purge)',
        'Wants'       => 'cassandra-backup-cleanup.timer',
      },
      service_entry => {
        'Type'      => 'oneshot',
        'ExecStart' => '/opt/medusa/bin/medusa purge',
      },
      install_entry => {
        'WantedBy' => 'multi-user.target',
      },
      require       => File['/etc/medusa/medusa.ini'],
    }
  }
}
