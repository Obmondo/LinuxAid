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
# @param access_key_id S3 access key the upload authenticates with.
#
# @param secret_access_key S3 secret for that key. Keep it in eyaml.
#
# @param min_dump_bytes A dump smaller than this is treated as failed rather
#   than uploaded. Guards against a truncated dump evicting good backups. This
#   is only a floor - verify_dump also requires the dump to be at least half
#   the size of the previous one, which is what actually catches truncation.
#
# @groups backup enable
#
# @groups storage backup_dir, source_dir, s3_bucket, s3_endpoint
#
# @groups credentials access_key_id, secret_access_key
#
class common::backup::gitea (
  Pattern[/\As3:\/\/[a-z0-9][a-z0-9.\-]*\/\z/] $s3_bucket,
  Stdlib::HTTPUrl                              $s3_endpoint,
  Boolean                                      $enable            = false,
  Stdlib::Absolutepath                         $backup_dir        = '/opt/gitea/backup',
  Stdlib::Absolutepath                         $source_dir        = '/opt/gitea/data/git',
  Optional[String[1]]                          $access_key_id     = undef,
  Optional[Sensitive[String[1]]]               $secret_access_key = undef,
  Integer[1]                                   $min_dump_bytes    = 1073741824,
) {

  # verify_dump checks the archive's CRCs before the dump is uploaded or allowed
  # to evict an older one, so the tool has to be present rather than assumed.
  if $enable {
    stdlib::ensure_packages(['unzip'])
  }

  file { '/opt/obmondo/bin/gitea-backup':
    ensure  => ensure_file($enable),
    mode    => '0755',
    content => epp('common/backup/gitea-backup.sh.epp', {
      backup_dir        => $backup_dir,
      container         => 'gitea',
      container_user    => 'git',
      max_local_backups => 1,
      max_s3_backups    => 3,
      min_dump_bytes    => $min_dump_bytes,
      s3_bucket         => $s3_bucket,
      s3_endpoint       => $s3_endpoint,
      source_dir        => $source_dir,
      upload_timeout    => 900,
    }),
  }

  # The credentials the upload uses. These were previously left unmanaged in
  # /root/.aws/credentials, so the endpoint and the key it authenticates
  # against could drift apart - changing one without the other fails the
  # nightly backup with InvalidAccessKeyId, and nothing in git showed why.
  if $enable and $access_key_id and $secret_access_key {
    file { '/root/.aws':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0700',
    }

    file { '/root/.aws/credentials':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0600',
      show_diff => false,
      content   => Sensitive(@("EOT")),
                   # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
                   [default]
                   aws_access_key_id = ${access_key_id}
                   aws_secret_access_key = ${secret_access_key.unwrap}
                   | EOT
      require   => File['/root/.aws'],
    }
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
