# Manager http
class kolab::httpd (
  $ssl                 = false,
  $upload_max_filesize = undef,
  $post_max_size       = undef,
) {

  # Base class
  include apache

  # Need PHP
  contain ::apache::mod::php
  php::config { 'max-upload':
    file   => '/etc/php.ini',
    config => {
      'PHP/upload_max_filesize' => $upload_max_filesize,
      'PHP/post_max_size'       => $post_max_size,
    },
    notify => Service['httpd'],
  }
  # Create directory
  file { '/opt/kolab_vhosts' :
    ensure => directory
  }

  # Setup the conf files
  $httpd_conf_files = [
    'chwala.conf',
    'iRony.conf',
    'kolab-autoconf.conf',
    'kolab-freebusy.conf',
    'kolab-syncroton.conf',
    'kolab-webadmin.conf',
    'roundcubemail.conf',
  ]

  $httpd_conf_files.each | $httpd_conf_file | {
    file { "/opt/kolab_vhosts/${httpd_conf_file}" :
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => "puppet:///modules/kolab/${httpd_conf_file}",
      require => [ Class['::apache'], File['/opt/kolab_vhosts'] ],
      notify  => Class['::apache::service']
    }
  }

  if ( $ssl ) {
    # Firewall
    ensure_resource('firewall', '000 allow https', {
      proto  => 'tcp',
      dport  => 443,
      jump   => 'accept'
    })

    # Listen on 443
    ::apache::listen { '443': }

    # Setup SSL
    contain ::apache::mod::ssl

    # Setup vhost
    ::apache::vhost { $::kolab::cert_commonname :
      ssl                 => true,
      ssl_cert            => $::kolab::kolab_server_cert,
      ssl_key             => $::kolab::kolab_server_key,
      ssl_ca              => $::kolab::kolab_server_ca_file,
      port                => 443,
      docroot             => '/var/www/html',
      default_vhost       => true,
      additional_includes => '/opt/kolab_vhosts'
    }
  } else {
    # Firewall
    ensure_resource('firewall', '000 allow http', {
      proto  => 'tcp',
      dport  => 80,
      jump   => 'accept'
    })

    # Setup vhost
    ::apache::vhost { $::kolab::cert_commonname :
      docroot             => '/var/www/html',
      default_vhost       => true,
      additional_includes => '/opt/kolab_vhosts'
    }
  }
}
