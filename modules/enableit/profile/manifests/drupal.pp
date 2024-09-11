# Setup Drupal
class profile::drupal (
  Boolean
    $ssl         = false,
  Enum['::role::appeng::phpfpm', '::role::appeng::mod_php']
    $php         = '::role::appeng::mod_php',
  Enum['mysql']
    $dbdriver    = 'mysql',
  String
    $url         = "drupal.${::domain}",
  Enum['apache']
    $http_server = 'apache',
  String
    $password    = 'drupal_xyz',
) {

  $installroot = '/usr/share/drupal'

  ensure_packages('tar')

  if $http_server == 'apache' {
    # Pass phpfpm config, only when phpfpm is running
    if $php == '::role::appeng::phpfpm' {
      $proxy_pass_match = [ { 'path' => '^/(.*\.php)$', 'url' => "fcgi://127.0.0.1:9001/var/www/${url}/\$1" } ]

      # Setup apache
      if ( ! defined(Class['profile::web::apache']) ) {
        class { 'profile::web::apache': fastcgi => true, ssl => $ssl }
      }

      $user = 'phpfpm'
    } else {
      $proxy_pass_match = undef

      # Setup apache
      if ( ! defined(Class['profile::web::apache']) ) {
        class { 'profile::web::apache':
          php   => true,
          https => $ssl
        }
      }
    }

    if $ssl {
      apache::vhost { "${url}_443" :
        ssl              => true,
        port             => 443,
        servername       => $url,
        docroot          => "/var/www/${url}",
        docroot_owner    => 'root',
        docroot_group    => 'root',
        override         => [ 'All' ],
        manage_docroot   => false,
        proxy_pass_match => $proxy_pass_match,
        require          => Class['profile::web::apache'],
      }
    }
    # Setup the apache vhosts
    apache::vhost { $url :
      port             => 80,
      docroot          => "/var/www/${url}",
      docroot_owner    => 'root',
      docroot_group    => 'root',
      override         => [ 'All' ],
      manage_docroot   => false,
      proxy_pass_match => $proxy_pass_match,
      require          => Class['profile::web::apache'],
    }
  }

  # Setup Drupal
  class { '::drupal' :
    install_dir => $installroot,
    www_process => $user,
    require     => Class["profile::web::${http_server}"],
  }

  drupal::site { $url :
    core_version => '7.43',
  }

  # Setup the DB
  case $dbdriver {
    'mysql' : {
      mysql_user { 'drupal@localhost' :
        ensure        => present,
        password_hash => mysql_password($password),
      }

      -> mysql_grant { 'drupal@localhost/drupal.*' :
        ensure     => 'present',
        user       => 'drupal@localhost',
        table      => 'drupal.*',
        options    => [ 'GRANT' ],
        privileges => [ 'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'INDEX', 'ALTER', 'CREATE' ],
      }

      -> mysql_database { 'drupal' :
        ensure => present,
      }
    }
    default: {
      fail('Unsupported DB')
    }

  }
}
