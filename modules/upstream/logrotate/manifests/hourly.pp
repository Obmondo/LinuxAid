# Internal: Configure a host for hourly logrotate jobs.
#
# ensure - The desired state of hourly logrotate support.  Valid values are
#          'absent' and 'present' (default: 'present').
#
# Examples
#
#   # Set up hourly logrotate jobs
#   class { 'logrotate':
#     manage_cron_hourly => true,
#   }
#
#   # Remove hourly logrotate job support
#   class { 'logrotate':
#     manage_cron_hourly => true,
#     ensure_cron_hourly => absent,
#   }
class logrotate::hourly (
) {
  assert_private()

  file { "${logrotate::rules_configdir}/hourly":
    ensure => 'directory',
    owner  => $logrotate::root_user,
    group  => $logrotate::root_group,
    mode   => $logrotate::rules_configdir_mode,
    force  => true,
  }

  if $logrotate::manage_cron_hourly {
    logrotate::cron { 'hourly':
      ensure  => $logrotate::ensure_cron_hourly,
      require => File["${logrotate::rules_configdir}/hourly"],
    }
  }

  # Make copies of the rpm provided unit and timers
  if $logrotate::manage_systemd_timer {
    $_lockfile = '/run/lock/logrotate.service'
    $_timeout  = 21600
    systemd::manage_dropin { 'hourly-service.conf':
      ensure        => $logrotate::ensure_systemd_timer,
      unit          => 'logrotate-hourly.service',
      unit_entry    => {
        'Description' => [
          '',
          'Extra service to run hourly logrotates only',
        ],
      },
      service_entry => {
        'ExecStart' => ['', "/usr/bin/flock --wait ${_timeout} ${_lockfile} /usr/sbin/logrotate ${logrotate::rules_configdir}/hourly"],
      },
      before        => Systemd::Unit_file['logrotate-hourly.service'],
    }

    # Once logrotate >= 3.21.1 replace flock with the `--wait-for-state-lock` option.
    systemd::manage_dropin { 'logrotate-flock.conf':
      ensure        => $logrotate::ensure_systemd_timer,
      unit          => 'logrotate.service',
      service_entry => {
        'ExecStart'   => ['', "/usr/bin/flock --wait ${_timeout} ${_lockfile} /usr/sbin/logrotate /etc/logrotate.conf"],
      },
    }

    systemd::unit_file { 'logrotate-hourly.service':
      ensure => $logrotate::ensure_systemd_timer,
      source => 'file:///lib/systemd/system/logrotate.service',
      before => Systemd::Unit_file['logrotate-hourly.timer'],
    }

    systemd::manage_dropin { 'hourly-timer.conf':
      ensure      => $logrotate::ensure_systemd_timer,
      unit        => 'logrotate-hourly.timer',
      unit_entry  => {
        'Description' => [
          '',
          'Extra timer to run hourly logrotates only',
        ],
      },
      timer_entry => {
        'OnCalendar'   => ['', 'hourly'],
      },
      before      => Systemd::Unit_file['logrotate-hourly.timer'],
    }

    $_timer = $logrotate::ensure_systemd_timer ? {
      'present' => true,
      default  => false,
    }

    systemd::unit_file { 'logrotate-hourly.timer':
      ensure => $logrotate::ensure_systemd_timer,
      source => 'file:///lib/systemd/system/logrotate.timer',
      active => $_timer,
      enable => $_timer,
    }
  }
}
