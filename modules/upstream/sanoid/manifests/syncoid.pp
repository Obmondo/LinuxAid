# Sanoid Replication
class sanoid::syncoid (
  Boolean                            $enabled,
  Sanoid::Syncoid::Replications      $replications,
  Optional[Sanoid::Syncoid::Options] $default_options,
) {

  $replications.each |String $pool_name, Sanoid::Syncoid::Replication $config| {
    $source = $config['source']
    $destination = $config['destination']

    # Change the upgrade service timer timing.
    $_minutes = fqdn_rand(30, $facts['networking']['hostname'])

        # Merge default_options with job-specific options
    # Job-specific options override defaults
    $merged_options = $default_options ? {
      undef   => $config['options'],
      default => $config['options'] ? {
        undef   => $default_options,
        default => $default_options + $config['options'],
      }
    }

    # Build command line arguments
    $args = $merged_options ? {
      undef   => '',
      default => sanoid::build_syncoid_args($merged_options),
    }

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

  systemd::manage_unit{'syncoid-replication@.service':
    ensure        => 'present',
    enable        => true,
    active        => true,
    unit_entry    => {
      'Description' => 'Syncoid Replication Service',
      'Wants'       => 'syncoid-replication-%i.timer',
    },
    service_entry => {
      'Type'            => 'oneshot',
      'ExecStart'       => "syncoid ${OPTIONS}",
      'EnvironmentFile' => '-/etc/default/sanoid-replication-%i',
    },
  }

}
