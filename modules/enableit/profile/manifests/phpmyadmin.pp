# PHPmyadmin Profile
class profile::phpmyadmin (
  $http_server  = 'apache',
  $ssl          = true,
  Enum['mod_php', 'phpfpm'] $php_runtime,
) {
  class { '::phpmyadmin' :
    manage_apache => false
  }

  $custom_conf = $::osfamily ? {
    'RedHat' => 'phpMyAdmin',
    'Debian' => 'phpmyadmin'
  }

  $conf_group = $::osfamily ? {
    'RedHat' => 'apache',
    'Debian' => 'www-data'
  }

  $conf_user = $php_runtime ? {
    'mod_php' => 'root',
    'phpfpm'  => 'phpfpm',
    default   => fail("Unsupported PHP runtime '${php_runtime}"),
  }

  $doc_path       = "/usr/share/${custom_conf}"
  $phpfpm         = getvar('::profile::web::apache::fastcgi')
  $apache_version = getvar('::apache::version::default')

  # Managing the phpmyadmin config
  file { "/etc/${custom_conf}/config.inc.php" :
    ensure => file,
    owner  => $conf_user,
    group  => $conf_group,
    mode   => '0640',
    source => 'puppet:///modules/profile/phpmyadmin.config.inc.php',
  }

  # manage vhost from here, not using vhost from phpmyadmin class
  # TODO check for centos6/2.2
  case $http_server {
    'apache': {
      case $php_runtime {
        'mod_php': {

          # If it is a normal mod_php
          $proxy_pass_match = undef
          $apache_notify = undef

          # Setup apache
          if ( ! defined(Class['profile::web::apache']) ) {
            class { 'profile::web::apache':
              php   => true,
              https => $ssl
            }
          }
        }
        'phpfpm': {
          # Pass phpfpm config, only when phpfpm is running
          $proxy_pass_match = [
            {
              'path' => '^/(.*\.php)$',
              'url'  => "fcgi://127.0.0.1:9001${doc_path}/\$1",
            },
          ]

          $apache_notify = Class['::php::fpm::pool']

          file { "/etc/${custom_conf}" :
            ensure => directory,
            owner  => 'phpfpm', # Need to check on ubuntu side
            mode   => '0750',
          }

          # Setup apache
          unless defined(Class['profile::web::apache']) {
            class { 'profile::web::apache':
              fastcgi => true,
              https   => $ssl,
            }
          }
        }
        default: {
          fail("Unsupported PHP runtime '${php_runtime}'")
        }
      }


      if $apache_version == '2.4' {
        $directories  = [
          {
            path                => "/usr/share/${custom_conf}",
            require             => 'all granted',
          },
          {
            path                => "/usr/share/${custom_conf}/setup/",
            require             => 'all granted',
          },
          {
            path                => "/usr/share/${custom_conf}/libraries/",
            require             => 'all denied',
          },
          {
            path                => "/usr/share/${custom_conf}/setup/lib/",
            require             => 'all denied',
          },
          {
            path                => "/usr/share/${custom_conf}/setup/frames/",
            require             => 'all denied',
          },
        ]
      }

      if $apache_version == '2.2' {
        $directories   = [
          {
            path                => "/usr/share/${custom_conf}",
            order               => 'Deny,Allow',
            allow               => 'from All',
          },
          {
            path                => "/usr/share/${custom_conf}/setup/",
            order               => 'Deny,Allow',
            allow               => 'from All',
          },
          {
            path                => "/usr/share/${custom_conf}/libraries/",
            order               => 'Deny,Allow',
            deny                => 'from All',
            allow               => 'from None'
          },
          {
            path                => "/usr/share/${custom_conf}/setup/lib/",
            order               => 'Deny,Allow',
            deny                => 'from All',
            allow               => 'from None'
},
        {
          path                => "/usr/share/${custom_conf}/setup/frames/",
          order               => 'Deny,Allow',
          deny                => 'from All',
          allow               => 'from None'
        },
      ]
    }

    ::apache::vhost { "${::fqdn}_phpmyadmin" :
      port             => '443',
      ssl              => $ssl,
      docroot          => "/usr/share/${custom_conf}",
      docroot_owner    => 'root',
      docroot_group    => 'root',
      proxy_pass_match => $proxy_pass_match,
      aliases          => [
        {
          alias => '/phpMyAdmin',
          path  => "/usr/share/${custom_conf}"
        },
        {
          alias => '/phpmyadmin',
          path  => "/usr/share/${custom_conf}"
        },
      ],
        rewrites       => [
          {
            comment      => 'Redirect to HTTPS',
            rewrite_cond => ['%{HTTPS} off'],
            rewrite_rule => ['(.*) https://%{HTTP_HOST}%{REQUEST_URI}'],
          }
        ],
          directories  => $directories,
          notify       => $apache_notify,
    }

    }
    default: {
      fail("Unsupported HTTP server '${http_server}'")
    }
  }
}
