# @summary Backup Cassandra database using medusa with local storage
#
# @param enable Enable backup
#
# @groups enable enable.
#
class common::backup::cassandra (
  Boolean $enable = false,
) {
  $medusa_base_path  = '/var/lib/medusa/backups'
  $medusa_parent_dir = dirname($medusa_base_path)

  file {
    default:
      ensure => directory,
      mode   => '0755',
      owner  => 'cassandra',
      group  => 'cassandra',
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
      'cassandra_config_file' => '/etc/cassandra/default.conf/cassandra.yaml',
      'cql_username'          => '',
      'cql_password'          => '',
      'cql_host'              => '127.0.0.1',
      'cql_port'              => 9042,
      'storage_provider'      => 'local',
      'bucket_name'           => 'cassandra_backups',
      'base_path'             => $medusa_base_path,
      'max_backup_count'      => 10,
      'max_backup_age'        => 30,
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
      'OnCalendar' => '*-*-* 0:00:00',
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
      'ExecStart' => "/bin/bash -c '/opt/medusa/bin/medusa backup --backup-name=cassandra_snapshot_$(date +%%Y%%m%%d_%%H%%M%%S) --mode=full'",
    },
    install_entry => {
      'WantedBy' => 'multi-user.target',
    },
    require       => File['/etc/medusa/medusa.ini'],
  }

  systemd::manage_unit { 'cassandra-backup-cleanup.timer':
    ensure        => ensure_present($enable),
    enable        => true,
    active        => true,
    unit_entry    => {
      'Description' => 'Cassandra Backup Cleanup Timer',
      'Requires'    => 'cassandra-backup-cleanup.service',
    },
    timer_entry   => {
      'OnCalendar' => '*-*-* 1:00:00',
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
