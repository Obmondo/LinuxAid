# logrotate config
class logrotate::config {
  assert_private()

  file { $logrotate::rules_configdir:
    ensure  => directory,
    owner   => $logrotate::root_user,
    group   => $logrotate::root_group,
    purge   => $logrotate::purge_configdir,
    recurse => $logrotate::purge_configdir,
    mode    => $logrotate::rules_configdir_mode,
  }

  if $logrotate::manage_cron_daily {
    logrotate::cron { 'daily':
      ensure => $logrotate::ensure_cron_daily,
    }
  }

  if $logrotate::manage_systemd_timer {
    if $logrotate::ensure_systemd_timer == 'present' {
      service { 'logrotate.timer':
        ensure => 'running',
        enable => true,
      }
    } else {
      service { 'logrotate.timer':
        ensure => 'stopped',
        enable => false,
      }
    }
  }

  if $logrotate::config {
    logrotate::conf { $logrotate::logrotate_conf:
      * => $logrotate::config,
    }
  }
}
