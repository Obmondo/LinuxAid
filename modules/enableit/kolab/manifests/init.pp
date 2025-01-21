# Kolab class
class kolab (
  $domain                           = $facts['networking']['domain'],
  $cert_country                     = undef,
  $cert_organization                = undef,
  $cert_commonname                  = $kolab::params::cert_commonname,
  $cert_state                       = $kolab::params::cert_state,
  $cert_unit                        = $kolab::params::cert_unit,
  $cert_altnames                    = $kolab::params::cert_altnames,
  $cert_email                       = $kolab::params::cert_email,
  $cert_days                        = $kolab::params::cert_days,
  $cert_base_dir                    = $kolab::params::cert_base_dir,
  $cert_owner                       = $kolab::params::cert_owner,
  $cert_group                       = $kolab::params::cert_group,
  $cert_password                    = $kolab::params::cert_password,
  $cert_force                       = $kolab::params::cert_force,
  $cert_template                    = $kolab::params::cert_template,
  $cert_certname                    = $kolab::params::cert_certname,
  $generate_ssl                     = $kolab::params::generate_ssl,
  $kolab_server_key                 = $kolab::params::kolab_server_key,
  $kolab_server_cert                = $kolab::params::kolab_server_cert,
  $kolab_server_ca_file             = $kolab::params::kolab_server_ca_file,
  $ssl                              = $kolab::params::kolab_ssl,
  $dkim                             = $kolab::params::dkim,
  $timezone                         = $kolab::params::kolab_timezone,
  $myorigin                         = '$myhostname',
  $upload_max_filesize              = '$upload_max_filesize',
  $post_max_size                    = '$post_max_size',
  $mydomain                         = $domain,
  $myhostname                       = $facts['networking']['fqdn'],
  $mysql_host                       = $kolab::params::kolab_mysql_host,
  # NOTE: TODO: FIXME: the kolab installation workflow is bit odd/broken
  # so we use this module to setup the kolab by running the install script
  # and the install script save the password to some file, look at the installation
  # script below in the pp. after the first puppet run, copy the required password and
  # save it in hiera
  Optional[String] $mysql_password  = $kolab::params::kolab_mysql_password,
  $manage_postfix                   = $kolab::params::kolab_manage_postfix,
  $manage_epel_repo                 = $kolab::params::manage_epel_repo,
  $manage_database                  = $kolab::params::kolab_manage_database,
  $manage_kolab_repo                = $kolab::params::manage_kolab_repo,
  $manage_webserver                 = $kolab::params::kolab_manage_webserver,
  $mynetworks                       = $kolab::params::mynetworks,
  $cyrus_imap_password              = $kolab::params::kolab_cyrus_imap_password,
  $ldap_service_password            = $kolab::params::kolab_ldap_service_password,
  $ldap_directory_manager_password  = $kolab::params::kolab_ldap_directory_manager_password,
  $policy_uid                       = $kolab::params::kolab_policy_uid,
  $postscreen                       = $kolab::params::postscreen,
  $postscreen_cidr                  = $kolab::params::postscreen_cidr,
  $postscreen_dnsbl_reply           = $kolab::params::postscreen_dnsbl_reply,
  $primary_mail                     = $kolab::params::kolab_primary_mail,
  $imap_backend                     = $kolab::params::kolab_imap_backend,
  $sync_interval                    = $kolab::params::kolab_sync_interval,
  $auth_mechanism                   = $kolab::params::kolab_auth_mechanism,
  $default_locale                   = $kolab::params::kolab_default_locale,
  $domain_sync_interval             = $kolab::params::kolab_domain_sync_interval,
  $domain_default_quota             = $kolab::params::kolab_domain_default_quota,
  $domain_primary_mail              = $kolab::params::kolab_domain_primary_mail,
  $virtualhost_name                 = $kolab::params::virtualhost_name,
  Optional[Hash] $virtual_aliases   = {},
  $postscreen_whitelist_interfaces  = $kolab::params::postscreen_whitelist_interfaces,
) inherits kolab::params {

  if $facts['os']['release']['major'] != '7' {
    fail('Kolab currently only support CentOS 7')
  }

  if $manage_kolab_repo {
    class { 'kolab::repo' : stage => 'setup' }
  }

  if $manage_epel_repo {
    package { 'epel-release' :
      require => File['/etc/yum.repos.d/kolab.repo' ]
    }
  }

  $kolab_domain_part00 = split($domain, '[.]')[0]
  $kolab_domain_part01 = split($domain, '[.]')[1]

  # Install this plugin to download packages from kolab rather then epel repo
  #TODO: move this to module hiera
  package::install([
    'yum-plugin-priorities',
    'deltarpm',
    'openssl-libs',
    'php-mysqlnd',
    'php-pear',
    'php-mcrypt',
    'php-pear-MDB2',
    'php-pear-Net-Socket',
    'php-pear-Mail',
    'php-ZendFramework',
    'php-pear-Net-SMTP',
    'mongodb-server',
    'php-pear-HTTP-Request2',
    'php-Smarty',
    'php-pear-Mail-mimeDecode',
    'php-pear-Net-IDNA2',
    'php-Monolog',
    'php-pear-Auth-SASL',
    'roundcubemail',
    'amavisd-new',
    'python2-gnupg',
    'clamav-server-systemd',
    'clamav-server',
    'pykolab',
    'perl-Mail-DKIM',
    # Required kolab packages
    'kolab',
    'kolab-webadmin',
    'kolab-autoconf',
    'kolab-utils',
    'kolab-schema',
    'kolab-syncroton',
    'kolab-cli',
    'kolab-saslauthd',
    'kolab-ldap',
    'kolab-imap',
    'kolab-webclient',
    'kolab-freebusy',
    'kolab-conf',
    'kolab-server',
    'kolab-mta',
  ])

  concat { '/etc/kolab/kolab.conf' :
    ensure  => present,
    owner   => 'kolab-n',
    group   => 'kolab',
    mode    => '0640',
    warn    => true,
    notify  => Service['kolabd'],
    require => [ Package['kolab'], Exec['Setup Kolab'] ],
  }

  concat::fragment { 'kolab_conf' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_conf.erb'),
    order   => '30'
  }
  concat::fragment { 'kolab_ldap' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_ldap.erb'),
    order   => '30'
  }
  concat::fragment { 'kolab_smtp' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_smtp.erb'),
    order   => '40'
  }
  concat::fragment { 'kolab_wap' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_wap.erb'),
    order   => '50'
  }
  concat::fragment { 'kolab_cyrus' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_cyrus.erb'),
    order   => '60'
  }
  concat::fragment { 'kolab_sasl' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_sasl.erb'),
    order   => '70'
  }
  concat::fragment { 'kolab_wallace' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_wallace.erb'),
    order   => '80'
  }
  concat::fragment { 'kolab_domain' :
    target  => '/etc/kolab/kolab.conf',
    content => template('kolab/kolab_domain.erb'),
    order   => '99'
  }

  service { 'kolabd' :
    ensure  => running,
    enable  => true,
    require => Package['kolab']
  }

  service { 'kolab-saslauthd' :
    ensure  => running,
    enable  => true,
    require => Package['kolab-saslauthd']
  }

  if $manage_database {
    # Firewall
    ensure_resource('firewall', '000 allow mysql', {
      proto  => 'tcp',
      dport  => 3306,
      jump   => 'accept'
    })

    $mysqlserver = 'new'
  } else {
    #$mysqlserver = 'existing'
    fail("Currently it is not possible to run the 'setup-kolab' command with --mysqlserver=existing,
      since it waits for a mysql_password to be entered by user")
  }

  # Setup kolab
  exec { 'Setup Kolab' :
    path      => ['/usr/bin', '/usr/sbin'],
    command   => "setup-kolab --mysqlserver=${mysqlserver} --timezone=${timezone} --directory-manager-pwd=${ldap_directory_manager_password} --default > /etc/kolab/installation_password", #lint:ignore:140chars
    timeout   => '600',
    creates   => "/etc/dirsrv/slapd-${facts['networking']['hostname']}",
    logoutput => 'on_failure',
    require   => Package['kolab']
  }

  if ( $manage_postfix ) {
    class { 'kolab::postfix' :
      ssl                             => $ssl,
      dkim                            => $dkim,
      mynetworks                      => $mynetworks,
      myorigin                        => $myorigin,
      mydomain                        => $mydomain,
      myhostname                      => $myhostname,
      postscreen                      => $postscreen,
      postscreen_cidr                 => $postscreen_cidr,
      postscreen_dnsbl_reply          => $postscreen_dnsbl_reply,
      smtpd_tls_key_file              => $kolab_server_key,
      smtpd_tls_cert_file             => $kolab_server_cert,
      smtpd_tls_cafile                => $kolab_server_ca_file,
      virtualalias                    => $virtual_aliases,
      postscreen_whitelist_interfaces => $postscreen_whitelist_interfaces,
    }
  }

  if ( $manage_webserver ) {
    class { 'kolab::httpd' :
      ssl                 => $ssl,
      upload_max_filesize => $upload_max_filesize,
      post_max_size       => $post_max_size,
    }
  }

  if ( $generate_ssl ) {
    if $cert_country == undef {
      fail("cert_country is 'undef', please pass some values. If using \$ssl option")
    } elsif $cert_organization == undef {
      fail("cert_organization is 'undef', please pass some values. If using \$ssl option")
    }

    # Setup ssl certs
    class { 'kolab::ssl' : }
  }

  anchor    { 'kolab::start'     : }
  -> class  { 'kolab::guam'      : }
  -> class  { 'kolab::manticore' : }
  -> class  { 'kolab::wallace'   : }
  -> class  { 'kolab::amavisd'   : }
  -> class  { 'kolab::cyrus'     : }
  -> class  { 'kolab::roundcube' : }
  -> anchor { 'kolab::end'       : }
}
