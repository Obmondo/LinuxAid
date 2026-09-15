# @summary Class for managing Gitea backups
#
# @param s3_bucket The S3 bucket URI the dumps are uploaded to, trailing slash required.
#
# @param s3_endpoint The S3 endpoint URL used for the uploads.
#
# @param enable Boolean to enable or disable the backup. Defaults to false.
#
# @param backup_dir Directory holding the local copies of the dumps.
#
# @param source_dir Host directory gitea writes the dump archive to.
#
# @groups backup enable
#
# @groups storage backup_dir, source_dir, s3_bucket, s3_endpoint
#
class common::backup::gitea (
  Pattern[/\As3:\/\/[a-z0-9][a-z0-9.\-]*\/\z/] $s3_bucket,
  Stdlib::HTTPUrl                              $s3_endpoint,
  Boolean                                      $enable     = false,
  Stdlib::Absolutepath                         $backup_dir = '/opt/gitea/backup',
  Stdlib::Absolutepath                         $source_dir = '/opt/gitea/data/git',
) {

  file { '/opt/obmondo/bin/gitea-backup':
    ensure  => ensure_file($enable),
    mode    => '0755',
    content => epp('common/backup/gitea-backup.sh.epp', {
      backup_dir        => $backup_dir,
      container         => 'gitea',
      container_user    => 'git',
      max_local_backups => 1,
      max_s3_backups    => 3,
      s3_bucket         => $s3_bucket,
      s3_endpoint       => $s3_endpoint,
      source_dir        => $source_dir,
      upload_timeout    => 900,
    }),
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
