# Sanoid Replication
define sanoid::syncoid::replication (
  Boolean                            $enabled,
  Sanoid::Syncoid::Replication       $configs,
) {

  $pool_name = $title

  $source = "${configs['source']}:${pool_name}"
  $destination = $pool_name
  $default_options = $sanoid::syncoid::default_options

  # Change the upgrade service timer timing.
  $_minutes = fqdn_rand(30, $facts['networking']['hostname'])

  # Merge default_configs with job-specific configs
  # Job-specific configs override defaults
  $merged_options = $configs['options'] ? {
    undef   => $default_options,
    default => $default_options + $configs['options'],
  }

  # Build command line arguments
  $args = sanoid::build_syncoid_args($merged_options)

  # timer content
  $_timer = @("EOT"/$n)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=Syncoid Replication Timer
    Requires=syncoid-replication-${pool_name}.service
    [Timer]
    OnCalendar=*-*-* *:0/15:00
    RandomizedDelaySec=${_minutes}m
  | EOT

  file { "/etc/default/sanoid-replication-${pool_name}":
    ensure  => $enabled,
    content => "OPTIONS=${args} ${source} ${destination}"
  }

  systemd::timer { "sanoid-replication-${pool_name}.timer":
    ensure        => $enabled,
    timer_content => $_timer,
    active        => $enabled,
    enable        => $enabled,
    require       => Package['sanoid'],
  }
}
