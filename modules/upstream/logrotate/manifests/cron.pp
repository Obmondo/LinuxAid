#
define logrotate::cron (
  $ensure = 'present'
) {
  $script_path = $facts['os']['family'] ? {
    'FreeBSD' => "/usr/local/bin/logrotate.${name}.sh",
    default   => "/etc/cron.${name}/logrotate",
  }

  $logrotate_path = $logrotate::logrotate_bin

  if $name == 'hourly' {
    $logrotate_conf = "${logrotate::rules_configdir}/hourly"
  } else {
    $logrotate_conf = $logrotate::logrotate_conf
  }

  # If the logrotation config file is not yet in the arguments, add it
  if ! ($logrotate_conf in $logrotate::logrotate_args) {
    $_logrotate_args = concat($logrotate::logrotate_args,$logrotate_conf)
  }
  else {
    $_logrotate_args = $logrotate::logrotate_args
  }

  $cron_always_output = $logrotate::cron_always_output

  $logrotate_args = join($_logrotate_args, ' ')

  # FreeBSD does not have /etc/cron.daily, so we need to have Puppet maintain
  # a crontab entry
  if $facts['os']['family'] == 'FreeBSD' {
    if $name == 'hourly' {
      $cron_hour   = '*'
      $cron_minute = $logrotate::cron_hourly_minute
    } else {
      $cron_hour   = $logrotate::cron_daily_hour
      $cron_minute = $logrotate::cron_daily_minute
    }

    cron { "logrotate_${name}":
      minute  => $cron_minute,
      hour    => $cron_hour,
      command => $script_path,
      user    => 'root',
    }
  }

  file { $script_path:
    ensure  => $ensure,
    owner   => $logrotate::root_user,
    group   => $logrotate::root_group,
    mode    => $logrotate::cron_file_mode,
    content => template('logrotate/etc/cron/logrotate.erb'),
  }
}
