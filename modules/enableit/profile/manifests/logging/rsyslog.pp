# rsyslog
class profile::logging::rsyslog (
  Boolean                       $enable          = $::common::logging::rsyslog::enable,
  Boolean                       $purge_rsyslog_d = $::common::logging::rsyslog::purge_rsyslog_d,
  Boolean                       $log_remote      = $::common::logging::rsyslog::log_remote,
  Boolean                       $log_local       = $::common::logging::rsyslog::log_local,
  Boolean                       $log_cron        = $::common::logging::rsyslog::log_cron,
  Boolean                       $log_mail        = $::common::logging::rsyslog::log_mail,
  Boolean                       $log_auth        = $::common::logging::rsyslog::log_auth,
  Boolean                       $log_boot        = $::common::logging::rsyslog::log_boot,
  Boolean                       $system_log      = $::common::logging::rsyslog::system_log,
  Eit_types::Rsyslog::Remote_Ip $remote_servers  = $::common::logging::rsyslog::remote_servers,
) {

  if $facts['os']['family'] == 'Suse' {
    $rsyslog_group = 'root'
  } else {
    $rsyslog_group = 'adm'
  }

  if $enable {
    $_rsyslog_lib_dir = '/var/lib/rsyslog'

    $_rsyslog_modules = if $facts['init_system'] == 'systemd' {
      {
        'imjournal' => {
          'config' => {
            'StateFile'              => "${_rsyslog_lib_dir}/imjournal.state",
            'IgnorePreviousMessages' => 'off',
            'Ratelimit.Interval'     => '600',
            'Ratelimit.Burst'        => '20000',
          }
        },
      }
    } else {
      {}
    }

    if versioncmp($facts.dig('rsyslog_version'), '8.20') < 1 {
      class { 'saz_rsyslog':
        purge_rsyslog_d      => $purge_rsyslog_d,
        spool_dir            => $_rsyslog_lib_dir,
        im_journal_statefile => if $facts['init_system'] == 'systemd' {
          "${_rsyslog_lib_dir}/imjournal.state"
        },
      }

      $_remote_servers = $remote_servers.map |$rs, $val| {
        {
          'host' => $rs,
        }
      }

      if $log_local or $log_remote {
        class { 'saz_rsyslog::client':
          log_remote       => $log_remote,
          log_local        => $log_local,
          remote_servers   => $_remote_servers,
          split_config     => true,
          listen_localhost => true,
          require          => File[$_rsyslog_lib_dir],
        }
      }
    } else {
      file { $_rsyslog_lib_dir:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0700',
      }

      File {
        ensure => 'file',
        group => $rsyslog_group,
        mode  => '0640',
      }

      $_remote_servers = $remote_servers.reduce({}) |$memo, $x| {
        [$rs, $value] = $x

        $_port = $value['port']
        $_proto = $value['proto'] ? {
          'tcp' => '@@',
          'udp' => '@'
        }

        $_rs = {
          "remote_server_${rs}_${_port}" => {
            key   => '*.*',
            value => "${_proto}${rs}:${_port}",
          },
        }

        $memo + $_rs
      }

      # remove logrotate rsyslog cron if using journald only for systemd servers
      if !$log_local {
        file { '/etc/logrotate.d/rsyslog':
          ensure => absent,
        }
      }

      $_auth_logs = if $log_auth {
        file { '/var/log/auth.log': }

        Hash([
          'auth', {
            key => 'auth,authpriv.*',
            value => '/var/log/auth.log',
          },
        ])
      }

      $_cron_logs = if $log_cron {
        file { '/var/log/cron.log': }

        Hash(['cron', {
          key   => 'cron.*',
          value => '/var/log/cron.log',
        }])
      }

      $_mail_logs = if $log_mail {
        file { '/var/log/mail.log': }

        Hash([
          'mail', {
            key => 'mail.*',
            value => '-/var/log/mail.log',
          },
          'mail2', {
                key => 'mail.err',
                value => '/var/log/mail.err',
          },
        ])
      }

      $_boot_logs = if $log_boot {
        file { '/var/log/boot.log': }

        Hash([
          'boot', {
          key   => 'local7.*',
          value => '-/var/log/boot.log',
          },
        ])
      }

      $_standard_logs = merge($_auth_logs, $_cron_logs, $_mail_logs)

      case $facts['os']['family'] {
        'RedHat', 'Suse': {
          $omfile_setting = {
            'fileOwner'      => 'root',
            'fileGroup'      => $rsyslog_group,
            'fileCreateMode' => '0640',
            'dirOwner'       => 'root',
            'dirGroup'       => 'root',
            'dirCreateMode'  => '0750',
          }

        }
        'Debian': {
          $omfile_setting = {
            'fileOwner'      => 'root',
            'fileGroup'      => 'adm',
            'fileCreateMode' => '0640',
            'dirOwner'       => 'root',
            'dirGroup'       => 'syslog',
            'dirCreateMode'  => '0755',
          }
        }
        default: {
          fail('unsupported')
        }
      }

      $os_rules = case $facts['os']['family'] {
        /RedHat|Suse/: {
          merge(
            if $system_log {
              file { '/var/log/messages': }

              Hash([
                'messages_rule', {
                  key   => '*.info;mail.none;authpriv.none;cron.none',
                  value => '/var/log/messages',
                },
              ])
            },
          )
        }
        'Debian': {
          stdlib::merge(
            if $system_log {
              file { ['/var/log/daemon.log', '/var/log/debug']: }

              Hash([
                'daemon', {
                  key   => 'daemon.*',
                  value => '-/var/log/daemon.log',
                },
                'debug_catch_all', {
                  key   => '*.=debug;auth,authpriv.none;news.none;mail.none',
                  value => '-/var/log/debug',
                },
                'catch_all', {
                  key   => '*.=info;*.=notice;*.=warn;auth,authpriv.none;cron,daemon.none;mail,news.none',
                  value => '-/var/log/messages',
                },
              ])
            },
          )
        }
        default: {
          fail('unsupported')
        }
      }

      $log_rules = if $log_local {
        merge($_boot_logs, $os_rules)
      }

      # This file  with Ubuntu and will cause journal logs to be
      # duplicated into `/var/log/syslog`, which is overkill.
      file { '/etc/rsyslog.d/50-default.conf':
        ensure => 'absent',
        before => Service['rsyslog'],
      }

      class { 'rsyslog':
        purge_config_files => $purge_rsyslog_d,
      }

      class { 'rsyslog::config':
        global_config => {
          'workDirectory'              => {
            'type'  => 'legacy',
            'value' => '/var/spool/rsyslog',
          },
          'maxMessageSize'             => {
            'type'  => 'legacy',
            'value' => '64k'
          },
          'ActionFileDefaultTemplate'  => {
            'type'  => 'legacy',
            'value' => 'RSYSLOG_TraditionalFileFormat'
          },
          'ActionQueueFileName'        => {
            'type'  => 'legacy',
            'value' => 'queue'
          },
          'ActionQueueMaxDiskSpace'    => {
            'type'  => 'legacy',
            'value' => '1g'
          },
          'ActionQueueSaveOnShutdown'  => {
            'type'  => 'legacy',
            'value' => 'on'
          },
          'ActionQueueType'            => {
            'type'  => 'legacy',
            'value' => 'LinkedList'
          },
          'ActionResumeRetryCount'     => {
            'type'  => 'legacy',
            'value' => '-1'
          },
          'SystemLogRateLimitBurst'    => {
            'type'  => 'legacy',
            'value' => '100'
          },
          'SystemLogRateLimitInterval' => {
            'type'  => 'legacy',
            'value' => '1'
          },
        },
        modules       => {
          'imuxsock' => {},
          'imklog'   => {},
          'imudp'    => {},
          'omusrmsg' => {
            'type'   => 'builtin',
          },
          'omfile'   => {
            'type'   => 'builtin',
            'config' => $omfile_setting,
          },
        } + $_rsyslog_modules,
        require       => File[$_rsyslog_lib_dir],
        inputs        => {
          'imudp' => {
            'type'   => 'imudp',
            'config' => {
              'Port'    => '514',
              'Address' => '127.0.0.1',
            },
          }
        },
        legacy_config => merge($_standard_logs, $log_rules, $_remote_servers),
      }
    }

  } else {
    service { 'rsyslog':
      ensure => 'stopped',
      enable => false,
    }
  }
}
