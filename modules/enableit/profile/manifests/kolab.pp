# kolab profile
class profile::kolab (
  Boolean                   $manage_database  = true,
  Boolean                   $manage_epel_repo = false,
  Boolean                   $manage_postfix   = true,
  Eit_types::Domain         $domain           = $facts['networking']['domain'],
  Boolean                   $dkim             = false,
  Array[Eit_types::Domain]  $dkim_domains     = [],
  Array[Eit_types::IP]      $dkim_ips         = [],
) {

  # Monitoring
  contain common::monitor::postfix

  # DKIM
  if $dkim {
    include opendkim

    # Trusted Domains
    opendkim::domain  { $dkim_domains : }

    # Trusted IPs
    opendkim::trusted { $dkim_ips : }
  }

  # Apache
  contain ::profile::web::apache

  # Logrotate
  contain ::profile::logrotate

  logrotate::rule { 'maillog' :
    path          => '/var/log/maillog',
    rotate        => 30,
    missingok     => true,
    compress      => true,
    delaycompress => true,
    ifempty       => false,
    create        => true,
    create_mode   => '0600',
    rotate_every  => 'day',
    sharedscripts => true,
    postrotate    => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
  }

  # Mysql
  # The reason of require'ng kolab first because setup-kolab command setup the database
  # by itself and passing existing to the command line does not help

  class { '::profile::mysql' :
    webadmin => false,
    require  => Class['::kolab'],
  }

  # Kolab
  class { '::kolab' :
    domain           => $domain,
    manage_database  => $manage_database,
    manage_epel_repo => $manage_epel_repo,
    manage_postfix   => $manage_postfix,
    notify           => Class['::profile::mysql'],
  }
}
