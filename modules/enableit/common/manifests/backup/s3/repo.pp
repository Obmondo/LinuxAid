# @summary Push local directories to an S3 bucket with restic
#
# The data is encrypted with the repository password before it leaves the
# host, deduplicated against earlier snapshots and pruned per the keep_*
# settings. The repository is initialised on the first run.
#
# Installs /opt/obmondo/bin/restic-s3-<name>, which runs the backup when called
# without arguments and otherwise passes its arguments to restic with the
# repository credentials loaded, so `restic-s3-<name> snapshots` or
# `restic-s3-<name> restore latest --target /tmp/restore` work as is.
#
# @param paths Local directories to back up.
#
# @param endpoint S3 endpoint URL, e.g. https://s3.obmondo.com.
#
# @param bucket Bucket the restic repository lives in. Created by restic on
#   the first run if it does not exist.
#
# @param access_key_id S3 access key the upload authenticates with.
#
# @param secret_access_key S3 secret for that key. Keep it in eyaml.
#
# @param password Restic repository password. Keep it in eyaml - without it
#   the backups can not be restored.
#
# @param timespec When to run the backup. Leave undef when trigger_after is
#   used instead.
#
# @param trigger_after A systemd unit after whose successful run the backup is
#   started, e.g. 'mailcow-backup.service', so the upload never races the job
#   that produces the files.
#
# @param randomized_delay Random delay added to timespec.
#
# @param keep_daily Number of daily snapshots to keep.
#
# @param keep_weekly Number of weekly snapshots to keep.
#
# @param keep_monthly Number of monthly snapshots to keep.
#
define common::backup::s3::repo (
  Array[Stdlib::Absolutepath, 1]                $paths,
  Stdlib::HTTPUrl                               $endpoint,
  Pattern[/\A[a-z0-9][a-z0-9.\-]{1,61}[a-z0-9]\z/] $bucket,
  String[1]                                     $access_key_id,
  String[1]                                     $secret_access_key,
  String[1]                                     $password,
  Optional[Eit_types::SystemdTime]              $timespec         = undef,
  Optional[Systemd::Unit]                       $trigger_after    = undef,
  Eit_types::SystemdTimeSpan                    $randomized_delay = '10 minutes',
  Integer[0]                                    $keep_daily       = 7,
  Integer[0]                                    $keep_weekly      = 4,
  Integer[0]                                    $keep_monthly     = 6,
) {

  unless $name =~ /\A[a-z0-9][a-z0-9_-]*\z/ {
    fail("common::backup::s3::repo: '${name}' is not a valid repository name, use lowercase letters, digits, '-' and '_'")
  }

  confine(!$timespec and !$trigger_after,
    "common::backup::s3::repo ${name}: set either timespec or trigger_after, otherwise the backup never runs")

  stdlib::ensure_packages(['restic'])

  $_conf_dir      = '/etc/obmondo/restic'
  $_env_file      = "${_conf_dir}/${name}.env"
  $_password_file = "${_conf_dir}/${name}.password"
  $_script        = "/opt/obmondo/bin/restic-s3-${name}"
  $_unit          = "obmondo-backup-s3-${name}"

  ensure_resource('file', $_conf_dir, {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  })

  file { $_env_file:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => Sensitive(@("EOT")),
                 # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
                 export RESTIC_REPOSITORY='s3:${endpoint.regsubst('/+\z', '')}/${bucket}'
                 export RESTIC_PASSWORD_FILE='${_password_file}'
                 export RESTIC_CACHE_DIR='/var/cache/restic/${name}'
                 export AWS_ACCESS_KEY_ID='${access_key_id}'
                 export AWS_SECRET_ACCESS_KEY='${secret_access_key}'
                 | EOT
    require   => File[$_conf_dir],
  }

  # A file of its own, so the password is used verbatim whatever it contains
  file { $_password_file:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => Sensitive($password),
    require   => File[$_conf_dir],
  }

  file { $_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('common/backup/restic-s3.sh.epp', {
      env_file     => $_env_file,
      paths        => $paths,
      keep_daily   => $keep_daily,
      keep_weekly  => $keep_weekly,
      keep_monthly => $keep_monthly,
    }),
  }

  $_service = @("EOT"/$n)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Obmondo restic backup of ${name} to S3
    Wants=network-online.target
    After=network-online.target

    [Service]
    Type=oneshot
    ExecStart=${_script}
    Nice=10
    IOSchedulingClass=idle
    TimeoutStartSec=6h
    | EOT

  if $timespec {
    $_timer = @("EOT"/$n)
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      [Unit]
      Description=Obmondo restic backup of ${name} to S3

      [Install]
      WantedBy=timers.target

      [Timer]
      OnCalendar=${systemd_make_timespec($timespec)}
      RandomizedDelaySec=${randomized_delay}
      Persistent=true
      | EOT

    systemd::timer { "${_unit}.timer":
      timer_content   => $_timer,
      service_content => $_service,
      active          => true,
      enable          => true,
      require         => File[$_script, $_env_file, $_password_file],
    }
  } else {
    systemd::unit_file { "${_unit}.service":
      content => $_service,
      require => File[$_script, $_env_file, $_password_file],
    }
  }

  if $trigger_after {
    # notify_service is off, a restart of the triggering unit would kick off
    # an unscheduled run of whatever job it is
    systemd::dropin_file { "obmondo-backup-s3-${name}.conf":
      unit           => $trigger_after,
      notify_service => false,
      content        => @("EOT"),
                        # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
                        [Unit]
                        OnSuccess=${_unit}.service
                        | EOT
    }
  }
}
