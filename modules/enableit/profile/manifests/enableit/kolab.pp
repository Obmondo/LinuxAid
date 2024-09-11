# kolab enableit profile
class profile::enableit::kolab (
  Optional[String]
    $mysql_monitor_username       = 'obmondo-mon',
  Optional[String]
    $mysql_monitor_password       = 'M0n1t0rE2',
  Optional[String]
    $mysql_monitor_hostname       = 'localhost',
  Optional[String]
    $upload_max_filesize          = $role::customers::enableit::kolab::upload_max_filesize,
  Optional[String]
    $post_max_size                = $role::customers::enableit::kolab::post_max_size,
) inherits profile::enableit {

  # Apache
  class { 'profile::web::apache':
    http    => true,
    https   => false,
    modules => [],
    vhosts  => {},
    ciphers => 'default',

  }

  File {
    default:
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      notify => [
        Service['postfix'],
        Service['cyrus-imapd'],
        Service['kolabd'],
      ],
    ;
    ['/etc/pki/tls/private/kolab.enableit.dk.key']:
      source => 'file:/etc/ssl/private/letsencrypt/kolab.enableit.dk/privkey.pem',
    ;
    ['/etc/pki/tls/certs/kolab.enableit.dk.crt']:
      source => 'file:/etc/ssl/private/letsencrypt/kolab.enableit.dk/cert.pem',
    ;
    ['/etc/pki/cyrus-imapd/kolab.enableit.dk.bundle.pem', '/etc/pki/tls/certs/kolab.enableit.dk.bundle.pem']:
      source => 'file:/etc/ssl/private/letsencrypt/enableit.dk.pem',
    ;
  }

  # logrotate for maillog
  logrotate::rule { 'maillog':
    ensure        => 'present',
    path          => '/var/log/maillog',
    rotate_every  => 'week',
    rotate        => 12,
    compress      => true,
    delaycompress => true,
    postrotate    => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
  }

  # Kolab
  class { '::kolab' :
    ssl                             => true,
    dkim                            => true,
    postscreen                      => true,
    postscreen_cidr                 => [
      '10.0.0.0/8 permit',
    ],
    myorigin                        => 'enableit.dk',
    mydomain                        => 'enableit.dk',
    myhostname                      => 'kolab.enableit.dk',
    upload_max_filesize             => $upload_max_filesize,
    post_max_size                   => $post_max_size,
    mynetworks                      => '127.0.0.1,10.0.0.0/8,85.204.133.115,109.238.49.196,109.238.49.194,jabba.enableit.dk,144.76.69.71,78.46.72.21,176.9.124.207,85.10.211.48,138.201.82.121,138.201.224.126',
    postscreen_whitelist_interfaces => '127.0.0.1 10.0.0.0/8 88.198.47.134/32 109.238.49.196/32 109.238.49.194/32 static:all',
    manage_webserver                => true,
    manage_database                 => true,
    manage_epel_repo                => false,
    manage_postfix                  => true,
    domain                          => 'enableit.dk',
    kolab_server_key                => '/etc/pki/tls/private/kolab.enableit.dk.key',
    kolab_server_cert               => '/etc/pki/tls/certs/kolab.enableit.dk.crt',
    kolab_server_ca_file            => '/etc/pki/cyrus-imapd/kolab.enableit.dk.bundle.pem',
    ldap_directory_manager_password => 'bSmFX7SyKRLUCJM',
    virtualhost_name                => 'kolab.enableit.dk',
    virtual_aliases                 => {
      'info'                => 'klavs',
      'tdcmon@enableit.dk'  => 'klavs@enableit.dk',
      'bryan@enableit.dk'   => 'klavs@enableit.dk',
      'redmine@enableit.dk' => 'redmine',
    },
    domain_default_quota            => 4194304,
  }

  # pflogsumm.pl - Produce Postfix MTA logfile summary
  file { '/usr/local/sbin/pflogsumm.pl' :
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/profile/enableit/pflogsumm.pl',
  }

  # Mailalias
  mailalias { 'redmine':
    ensure    => present,
    recipient => "|/usr/local/bin/rdm-mailhandler.rb --url https://redmine.enableit.dk --key dpRCR6y6wZNrnduRQUe1 --project 'Customer Service'",
  }

  # Copied from common::mail
  # Run `newaliases` if needed
  exec { '/usr/bin/newaliases':
    # only run `newaliases` if the db is either missing or older than the
    # aliases file
    onlyif => '/usr/bin/test \( ! -f /etc/aliases.db \) -o \( /etc/aliases.db -ot /etc/aliases \)',
  }

}
