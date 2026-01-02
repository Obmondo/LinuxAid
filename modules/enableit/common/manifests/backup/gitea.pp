# @summary Class for managing Gitea backups
#
# @param enable Boolean to enable or disable the backup. Defaults to false.
#
# @param noop_value Optional boolean value for noop mode. Defaults to undef.
#
class common::backup::gitea (
  Boolean               $enable = false,
  Eit_types::Noop_Value $noop_value = undef,
) {

  file { '/opt/obmondo/bin/gitea-backup':
    ensure => ensure_file($enable),
    mode   => '0755',
    source => 'puppet:///modules/common/gitea/gitea-backup.sh',
  }

  $_timer = @("EOT"/$n)
# THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
[Unit]
Requires=gitea-backup.service
Description=Run gitea backup

[Install]
WantedBy=timers.target

[Timer]
OnCalendar=*-*-* 05:00:00
Persistent=true
Unit=gitea-backup.service
RandomizedDelaySec=1h
| EOT

  $_service = @(EOT)
# THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
[Unit]
Description=Run Gitea backup based on timer
Wants=gitea-backup.timer

[Service]
Type=oneshot
ExecStart=/opt/obmondo/bin/gitea-backup
| EOT

  systemd::timer { 'gitea-backup.timer':
    timer_content   => $_timer,
    service_content => $_service,
    active          => true,
    enable          => true,
  }
}
