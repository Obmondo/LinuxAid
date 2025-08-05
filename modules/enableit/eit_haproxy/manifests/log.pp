# Haproxy log class
class eit_haproxy::log (
  Boolean              $log_compressed = pick($eit_haproxy::log_compressed, false),
  Stdlib::Absolutepath $log_dir        = pick($eit_haproxy::log_dir, '/var/log'),
) {

  $defaults = $facts['os']['family'] ? {
    'Debian' => $::facts['os']['release']['major'] ? {
      8 => {
        owner => 'root',
        group => 'adm',
      },
      default => {
        owner => 'root',
        group => 'syslog',
      },
    },
    'RedHat' => {
      owner => 'root',
      group => 'root',
    }
  }

  $_logfile_name = if $log_compressed {
    "${log_dir}/haproxy.log.gz"
  } else {
    "${log_dir}/haproxy.log"
  }

  logrotate::rule { 'haproxy':
    ensure        => 'present',
    path          => $_logfile_name,
    rotate_every  => 'daily',
    rotate        => 30,
    missingok     => true,
    ifempty       => false,
    compress      => $log_compressed,
    delaycompress => $log_compressed,
    sharedscripts => true,
    dateext       => true,
    postrotate    => [
      'pkill -HUP rsyslogd',
    ],
    su            => true,
    su_user       => $defaults['owner'],
    su_group      => $defaults['group'],
  }

  rsyslog::component::expression_filter { 'haproxy':
    priority     => 55,
    target       => '55-haproxy.conf',
    confdir      => '/etc/rsyslog.d',
    conditionals => {
      'if' => {
        expression => '$programname startswith "haproxy"',
        tasks      => [
          action   => {
            'name'   => 'haproxy_log',
            'type'   => 'omfile',
            'config' => [
              {
                'File'          => $_logfile_name,
              },
              if $log_compressed {
                {
                  'asyncWriting'  => 'on',
                  'flushInterval' => '60',
                  'flushOnTXEnd'  => 'off',
                  'ioBufferSize'  => '256k',
                  'zipLevel'      => '6'
                }
              },
            ].merge_hashes
          },
          stop     => true,
        ]
      }
    }
  }

}
