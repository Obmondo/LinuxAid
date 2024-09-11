# Manage postfix
class kolab::postfix (
  Boolean              $ssl                             = false,
  Boolean              $dkim                            = false,
  String               $myorigin                        = '$myhostname',
  String               $mydomain                        = $::facts['domain'],
  String               $myhostname                      = $::facts['fqdn'],
  String               $mynetworks                      = '127.0.0.1',
  Boolean              $postscreen                      = false,
  Hash                 $virtualalias                    = {},
  Array[String]        $postscreen_cidr                 = ['192.168.254.0/24 permit'],
  Array[String]        $postscreen_dnsbl_reply          = ['secret.zen.dq.spamhaus.net   zen.spamhaus.org'],
  Stdlib::AbsolutePath $smtpd_tls_key_file              = '/etc/pki/tls/private/localhost.pem',
  Stdlib::AbsolutePath $smtpd_tls_cert_file             = '/etc/pki/tls/private/localhost.pem',
  Stdlib::AbsolutePath $smtpd_tls_cafile                = '/etc/pki/tls/private/localhost.pem',
  String               $postscreen_whitelist_interfaces = 'static:all',
  ) {
  assert_private()

  # Firewall
  firewall {
    default:
      jump   => 'accept',
    ;
    '000 allow smtp':
      proto => 'tcp',
      dport => 25
    ;
    '001 allow submission':
      proto => 'tcp',
      dport => 587,
    ;
  }

  if $ssl {
    firewall { '001 allow smtps':
      proto  => 'tcp',
      dport  => 465,
      jump   => 'accept',
    }
  }

  # SSL
  $ssl_options = if $ssl {
    {
      smtpd_tls_key_file  => $smtpd_tls_key_file,
      smtpd_tls_cert_file => $smtpd_tls_cert_file,
      smtpd_tls_CAfile    => $smtpd_tls_cafile,
    }
  } else {
    {}
  }

  # DKIM
  $dkim_options = if $dkim {
    {
      smtpd_milters         => 'inet:127.0.0.1:8891',
      non_smtpd_milters     => '$smtpd_milters',
      milter_default_action => 'accept',
      milter_protocol       => '2',
    }
  } else {
    {}
  }

  if $postscreen {
    firewall {'001 allow postscreen':
      proto  => 'tcp',
      dport  => 10465,
      jump   => 'accept',
    }

    common::services::systemd { 'postwhite.timer':
      ensure  => running,
      enable  => true,
      timer   => {
        'OnCalendar' => systemd_make_timespec({
          'year'   => '*',
          'month'  => '*',
          'day'    => '*',
          'hour'   => '0/3',
          'minute' => 0,
          'second' => 0,
        }),
        'Unit'       => 'postwhite.service',
      },
      unit    => {
        'Requires'  => 'postwhite.service',
      },
      require => File['/usr/local/bin/postwhite.sh'],
    }

    file { default:
      ensure => 'file',
      ;
      '/etc/postfix/postscreen_dnsbl_reply_map':
        content => template('kolab/postscreen_dnsbl_reply_map.erb'),
      ;

      '/usr/local/bin/postwhite.sh':
        mode   => '0755',
        source => 'puppet:///modules/kolab/postwhite.sh',
      ;

      '/etc/postwhite.conf':
        mode    => '0755',
        content => epp('kolab/postwhite.conf.epp', {}),
      ;
    }

    ensure_packages(['git'])

    vcsrepo { '/usr/local/bin/spf-tools' :
      ensure   => present,
      provider => 'git',
      source   => 'git://github.com/jsarenik/spf-tools.git',
    }
  }

  # POSTSCREEN
  $postscreen_options = if $postscreen {
    {
      postscreen_upstream_proxy_protocol => 'haproxy',
      postscreen_access_list             => 'permit_mynetworks, cidr:/etc/postfix/postscreen_spf_whitelist.cidr',
      postscreen_blacklist_action        => 'drop',
      postscreen_dnsbl_action            => 'enforce',
      postscreen_dnsbl_sites             => 'zen.spamhaus.org*3
        b.barracudacentral.org*2
        bl.spameatingmonkey.net*2
        dnsbl.ahbl.org*2
        bl.spamcop.net
        dnsbl.sorbs.net
        psbl.surriel.com
        bl.mailspike.net
        swl.spamhaus.org*-4
        list.dnswl.org=127.[0..255].[0..255].0*-2
        list.dnswl.org=127.[0..255].[0..255].1*-3
        list.dnswl.org=127.[0..255].[0..255].[2..255]*-4',
      postscreen_dnsbl_threshold        => '3',
      postscreen_greet_action           => 'enforce',
      postscreen_whitelist_interfaces   => $postscreen_whitelist_interfaces,
      postscreen_dnsbl_reply_map        => 'texthash:/etc/postfix/postscreen_dnsbl_reply_map',
      postscreen_bare_newline_action    => 'enforce',
      postscreen_bare_newline_enable    => 'yes',
      postscreen_non_smtp_command_enable => 'yes',
      postscreen_pipelining_enable      => 'yes',
    }
  } else {
    {}
  }

  # Default postfix extra options
  $default_options = {
    default_destination_concurrency_limit => '20',
    smtp_connection_cache_destinations    => false,
    soft_bounce                           => 'no',
    content_filter                        => 'smtp-amavis:[127.0.0.1]:10024',
    smtpd_tls_auth_only                   => 'yes',
    smtpd_sender_login_maps               => '$local_recipient_maps',
    submission_sender_restrictions        => 'reject_non_fqdn_sender, check_policy_service unix:private/submission_policy, permit_sasl_authenticated, reject', # lint:ignore:140chars
    submission_recipient_restrictions     => 'check_policy_service unix:private/submission_policy, permit_sasl_authenticated, reject',
    submission_data_restrictions          => 'check_policy_service unix:private/submission_policy',
    smtpd_tls_security_level              => 'may',
    smtp_tls_security_level               => 'may',
    smtpd_sasl_auth_enable                => 'yes',
    smtp_tls_protocols                    => '!SSLv2,!SSLv3',
    smtpd_tls_protocols                   => '!SSLv2,!SSLv3',
    smtpd_tls_mandatory_protocols         => '!SSLv2,!SSLv3',
    smtp_tls_mandatory_protocols          => '!SSLv2,!SSLv3',
    smtpd_tls_mandatory_ciphers           => 'high',
    smtpd_tls_eecdh_grade                 => 'ultra',
    tls_preempt_cipherlist                => 'yes',
    tls_high_cipherlist                   => 'EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:+CAMELLIA256:+AES256:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!ECDSA:CAMELLIA256-SHA:AES256-SHA:CAMELLIA128-SHA:AES128-SHA', # lint:ignore:140chars
  }

  # Final resulting hash
  $final_options = deep_merge($ssl_options, $dkim_options, $default_options, $postscreen_options)

  # Virtual Mail aliases
  class { 'postfix::virtualalias' :
    virtual => $virtualalias,
  }

  class { 'postfix::server' :
    compatibility_level          => '0',
    custom_master                => 'kolab/master.cf.erb',
    inet_interfaces              => 'all',
    mynetworks                   => $mynetworks,
    myhostname                   => $myhostname,
    myorigin                     => $myorigin,
    message_size_limit           => 30000000,
    mydomain                     => $mydomain,
    mydestination                => 'ldap:/etc/postfix/ldap/mydestination.cf',
    transport_maps               => 'ldap:/etc/postfix/ldap/transport_maps.cf, hash:/etc/postfix/transport',
    virtual_alias_maps           => [
      '$alias_maps, hash:/etc/postfix/virtual, ldap:/etc/postfix/ldap/virtual_alias_maps.cf, ldap:/etc/postfix/ldap/virtual_alias_maps_mailforwarding.cf, ldap:/etc/postfix/ldap/virtual_alias_maps_sharedfolders.cf, ldap:/etc/postfix/ldap/mailenabled_distgroups.cf, ldap:/etc/postfix/ldap/mailenabled_dynamic_distgroups.cf' # lint:ignore:140chars
    ],
    recipient_delimiter          => '+',
    local_recipient_maps         => 'ldap:/etc/postfix/ldap/local_recipient_maps.cf',
    smtpd_sender_restrictions    => [
      'permit_mynetworks, check_policy_service unix:private/sender_policy_incoming',
    ],
    smtpd_recipient_restrictions => [
      'permit_mynetworks',
      'reject_unauth_pipelining',
      'reject_rbl_client zen.spamhaus.org',
      'reject_non_fqdn_recipient',
      'reject_invalid_helo_hostname',
      'reject_unknown_recipient_domain',
      'reject_unauth_destination',
      'check_policy_service unix:private/recipient_policy_incoming',
      'permit',
    ],
    extra_main_parameters        => $final_options,
  }
}
