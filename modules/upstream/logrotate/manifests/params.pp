# == Class: logrotate::params
#
# Params class for logrotate module
#
class logrotate::params {
  case $facts['os']['family'] {
    'FreeBSD': {
      $configdir     = '/usr/local/etc'
      $root_group    = 'wheel'
      $logrotate_bin = '/usr/local/sbin/logrotate'
      $conf_params = {
        su_group => 'wheel',
      }
      $base_rules = {}
      $rule_default = {
        missingok    => true,
        rotate_every => 'monthly',
        create       => true,
        create_owner => 'root',
        create_group => 'utmp',
        rotate       => 1,
      }
    }
    'Debian': {
      $default_su = $facts['os']['name'] ? {
        'Ubuntu' => true,
        default  => false,
      }
      $default_su_user = $facts['os']['name'] ? {
        'Ubuntu' => 'root',
        default  => undef,
      }
      $default_su_group = $facts['os']['name'] ? {
        'Ubuntu'  => 'syslog',
        default   => undef
      }
      $conf_params = {
        su       => $default_su,
        su_user  => $default_su_user,
        su_group => $default_su_group,
      }
      $configdir     = '/etc'
      $root_group    = 'root'
      $logrotate_bin = '/usr/sbin/logrotate'
      $base_rules = {
        'wtmp' => {
          path        => '/var/log/wtmp',
          create_mode => '0664',
        },
        'btmp' => {
          path        => '/var/log/btmp',
          create_mode => '0600',
        },
      }
      $rule_default = {
        missingok    => true,
        rotate_every => 'monthly',
        create       => true,
        create_owner => 'root',
        create_group => 'utmp',
        rotate       => 1,
      }
    }
    'Gentoo': {
      $conf_params = {
        dateext  => true,
        compress => true,
        ifempty  => false,
        mail     => false,
        olddir   => false,
      }
      $configdir     = '/etc'
      $root_group    = 'root'
      $logrotate_bin = '/usr/bin/logrotate'
      $base_rules = {
        'wtmp' => {
          path        => '/var/log/wtmp',
          missingok   => false,
          create_mode => '0664',
          minsize     => '1M',
        },
        'btmp' => {
          path        => '/var/log/btmp',
          create_mode => '0600',
        },
      }
      $rule_default = {
        missingok    => true,
        rotate_every => 'monthly',
        create       => true,
        create_owner => 'root',
        create_group => 'utmp',
        rotate       => 1,
      }
    }
    'RedHat': {
      $conf_params = {
        dateext  => true,
        compress => true,
        ifempty  => false,
        mail     => false,
        olddir   => false,
      }
      $configdir     = '/etc'
      $root_group    = 'root'
      $logrotate_bin = '/usr/sbin/logrotate'

      $wtmp_missingok = versioncmp($facts['os']['release']['major'],'8') >= 0
      $base_rules = {
        'wtmp' => {
          path        => '/var/log/wtmp',
          missingok   => $wtmp_missingok,
          create_mode => '0664',
          minsize     => '1M',
        },
        'btmp' => {
          path        => '/var/log/btmp',
          create_mode => '0600',
        },
      }
      $rule_default = {
        missingok    => true,
        rotate_every => 'monthly',
        create       => true,
        create_owner => 'root',
        create_group => 'utmp',
        rotate       => 1,
      }
    }
    'SuSE': {
      $conf_params = {
        dateext  => true,
        compress => true,
        ifempty  => false,
        mail     => false,
        olddir   => false,
      }
      $configdir     = '/etc'
      $root_group    = 'root'
      $logrotate_bin = '/usr/sbin/logrotate'
      $base_rules = {
        'wtmp' => {
          path        => '/var/log/wtmp',
          create_mode => '0664',
          missingok   => false,
        },
        'btmp' => {
          path         => '/var/log/btmp',
          create_mode  => '0600',
          create_group => 'root',
        },
      }
      $rule_default = {
        missingok    => true,
        rotate_every => 'monthly',
        create       => true,
        create_owner => 'root',
        create_group => 'utmp',
        rotate       => 99,
        maxage       => 365,
        size         => '400k',
      }
    }
    default: {
      $configdir     = '/etc'
      $root_group    = 'root'
      $logrotate_bin = '/usr/sbin/logrotate'
      $base_rules = {}
      $conf_params = {}
      $rule_default = {
        missingok    => true,
        rotate_every => 'monthly',
        create       => true,
        create_owner => 'root',
        create_group => 'utmp',
        rotate       => 1,
      }
    }
  }
  $cron_daily_hour    = 1
  $cron_daily_minute  = 0
  $cron_hourly_minute = 1
  $config_file        = "${configdir}/logrotate.conf"
  $logrotate_conf     = "${configdir}/logrotate.conf"
  $manage_package     = true
  $root_user          = 'root'
  $rules_configdir    = "${configdir}/logrotate.d"

  # File modes (permissions)
  # - These may need to be moved to the osfamily case statement
  # - These are currently matching the RedHat RPM permissions
  $cron_file_mode = '0700'
  $logrotate_conf_mode = '0644'
  $rules_configdir_mode = '0755'
}
