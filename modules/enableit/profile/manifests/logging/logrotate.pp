# Manage logrotation
class profile::logging::logrotate (
  Boolean                                      $purge       = $::common::logging::logrotate::purge,
  Boolean                                      $dateext     = $::common::logging::logrotate::dateext,
  Boolean                                      $compress    = $::common::logging::logrotate::compress,
  Eit_types::Common::Logging::Logrotate::Rules $rules       = $::common::logging::logrotate::rules,
  Hash                                         $adv_options = {},

  Enum['cron', 'service'] $__scheduling_method = 'cron',
) {

  # The condition should be that if we are using SUSE OS, the logrotate group must be set to root.
  if $facts['os']['family'] == 'Suse' {
    $logrotate_group = 'root'
  } else {
    $logrotate_group = 'adm'
  }

  $default_config = {
    dateext  => $dateext,
    compress => $compress,
    mail     => false,
    olddir   => undef,
    ifempty  => false,
  }

  $_adv_options = deep_merge($default_config, $adv_options)

  class { '::logrotate':
    ensure              => 'latest',
    purge_configdir     => $purge,
    config              => {
      # logrotate will complain loudly if the log dir is writable by groups
      # other than root. On Debian/Ubuntu rsyslog runs as `syslog` so we need to
      # make sure that this group is allowed to have write access to log
      # dir. See #2494ccb84a782cc7a194c4d8155d4433cdbb1734.
      su       => $::common::logging::logrotate::su,
      su_user  => 'root',
      su_group => $::common::logging::log_dir_group,
    } + $_adv_options,
      # Do it ourselves to be able to log rotation
      manage_cron_daily => false,
  }

  $rules.each |$_name, $_config| {
    logrotate::rule { $_name:
      * => $_config,
    }
  }

  # for ts to get timestamps into logrotate output
  package::install('moreutils')

  # handle the logrotate cron script ourselves so we can log what logrotate does
  # for debian there is systemctl logrotate job which causes duplicate run of logrotate on debian

  case $__scheduling_method {
    'cron': {
      cron::daily { 'logrotate':
        command     => '(logrotate /etc/logrotate.conf 2>&1) | ts | tee -a /var/log/logrotate.log',
        environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
      }
    }
    'service': {
      # Taken care by logrotate::rule
      $_logrotate_cron = '/etc/cron.daily/logrotate'

      file { $_logrotate_cron:
        ensure => absent,
      }

    }
    default: {
      fail("unmanaged scheduling method ${__scheduling_method}")
    }
  }

  # remove OS packaged logrotate cron job
  logrotate::rule { 'logrotate-log':
    ensure        => 'present',
    path          => '/var/log/logrotate.log',
    rotate_every  => 'month',
    rotate        => 6,
    compress      => true,
    delaycompress => true,
    missingok     => true,
  }

  logrotate::rule { 'rsyslog':
    ensure        => 'present',
    path          => [
      '/var/log/auth.log',
      '/var/log/cron',
      '/var/log/cron.log',
      '/var/log/daemon.log',
      '/var/log/debug',
      '/var/log/kern.log',
      '/var/log/lpr.log',
      '/var/log/mail.err',
      '/var/log/mail.info',
      '/var/log/mail.log',
      '/var/log/mail.warn',
      '/var/log/maillog',
      '/var/log/messages',
      '/var/log/secure',
      '/var/log/spooler',
      '/var/log/user.log',
    ],
    missingok     => true,
    sharedscripts => true,
    postrotate    => '/usr/bin/pkill -HUP rsyslogd',
    create        => true,
    create_owner  => 'root',
    create_group  => $logrotate_group,
    create_mode   => '0640',
  }

  logrotate::rule { 'syslog':
    ensure => 'absent',
  }

}
