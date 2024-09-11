# Gitea Backups
class common::backup::gitea (
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
) {

  file { '/opt/obmondo/bin/gitea-backup':
    ensure => ensure_file($enable),
    mode   => '0755',
    source => 'puppet:///modules/common/gitea/gitea-backup.sh',
  }

common::services::systemd { 'gitea-backup.service':
  ensure     => 'stopped',
  noop_value => $noop_value,
  unit       => {
    'Description' => 'Gitea Backup',
    'Wants'       => 'gitea-backup.timer',  # Depend on the timer unit
  },
  service    => {
    'Type'            => 'simple',
    'RemainAfterExit' => 'yes',
    'ExecStart'       => '/opt/obmondo/bin/gitea-backup',
  }
}

common::services::systemd { 'gitea-backup.timer':
  ensure     => ensure_present($enable),
  noop_value => $noop_value,
  timer      => {
    'OnCalendar'         => 'daily',
    'RandomizedDelaySec' => '10m',
    'Persistent'         => 'true',
  },
}
}
