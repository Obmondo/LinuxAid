# Sanoid Replication
define sanoid::syncoid::job (
  Stdlib::Host                       $source,
  Boolean                            $enabled = true,
  Optional[Sanoid::Syncoid::Options] $options = undef,
) {

  $job_name = $title
  $_ensure = stdlib::ensure($enabled)
  $_source = "${source}:${job_name}"
  $default_options = $sanoid::syncoid::default_options

  # Change the upgrade service timer timing.
  $_minutes = fqdn_rand(30, $facts['networking']['hostname'])

  # Merge default_configs with job-specific configs
  # Job-specific configs override defaults
  $merged_options = $options ? {
    undef   => $default_options,
    default => $default_options + $options,
  }

  # Build command line arguments
  $args = sanoid::build_syncoid_args($merged_options)

  # Create configuration file for this job
  file { "/etc/syncoid/replication-${job_name}.conf":
    ensure  => $_ensure,
    content => epp('sanoid/syncoid-job.conf.epp', {
      'source'      => $_source,
      'destination' => $job_name,
      'args'        => $args,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => File['/etc/syncoid'],
  }

  systemd::timer { "syncoid-replication-${job_name}.timer":
    ensure        => $_ensure,
    timer_content => epp('sanoid/syncoid-replication.timer.epp', {
      'job_name'    => $job_name,
      'on_calendar' => "*-*-* *:0/${_minutes}:00",
    }),
    active        => $enabled,
    enable        => $enabled,
    require       => Package['sanoid'],
  }
}
