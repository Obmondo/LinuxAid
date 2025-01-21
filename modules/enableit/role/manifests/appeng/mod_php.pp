# Mod PHP role
class role::appeng::mod_php (
  Optional[Enum['apc', 'xcache']] $opcodecache  = undef,
  Optional[Eit_types::URL] $url                 = undef,
  Boolean $ssl                                  = false,
  Enum['apache', 'nginx'] $http_server          = 'apache',
  Boolean $mysql                                = false,
  Optional[Pattern[/[0-9]+[MG]/]] $memory_limit = undef,
) inherits ::role::appeng {

  class { '::profile::php' :
    url          => $url,
    ssl          => $ssl,
    mod_php      => true,
    http_server  => $http_server,
    opcodecache  => $opcodecache,
    mysql        => $mysql,
    memory_limit => $memory_limit,
  }

  # Calling profile::web::apache cause we are serving a complete webserver for role::appeng::*.
  # https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/mod/php.pp#L43
  # Dont run this block, because the vhost is getting set by phpfpm profile for phpfpm, otherwise set this block
  # TODO need to get nginx config, with simple cgi, fastcgi is already covered under profile::appeng::phpfpm.

  # Variables
  $docroot = '/var/www/html'
  $code = 'php'
  $codeupcase = upcase($code)

  if $http_server == 'apache' {
    class { '::profile::web::apache':
      php   => true,
      https => $ssl
    }

    # Setup the apache vhosts
    if $url {
      apache::vhost { $url:
        port          => '80',
        docroot       => $docroot,
        override      => 'all',
        docroot_owner => 'root',
        docroot_group => 'root',
        notify        => File["${docroot}/index.php"],
      }
    }

    # Admin vhost to get status for apache,php and more application
    apache::vhost { "${facts['networking']['hostname']}.local.${facts['networking']['domain']}":
      port            => '80',
      docroot         => '/var/www/html',
      servername      => "${facts['networking']['hostname']}.local.${facts['networking']['domain']}",
      custom_fragment => template('profile/httpd-defaultvhost.erb'),
    }
  }

  if $http_server == 'nginx' {
    class { '::profile::web::nginx':
        phpcache => $opcodecache
    }

    # Vhosts
    if $url != 'none' {
      ::nginx::resource::vhost { $url:
        listen_port => 80,
        www_root    => $docroot,
        server_name => $url,
        notify      => File["${docroot}/index.php"],
      }
    }

    # Setups the apc,xcache vhosts
    # default vhost for customer, like status for nginx and apc status
    $default_status_locations = {
      'allow' => [ '127.0.0.1', $facts['networking']['ip'] ],
      'deny'  => 'all',
    }

    ::nginx::resource::location { "${facts['networking']['fqdn']}-01":
      ensure              => present,
      stub_status         => true,
      vhost               => "${facts['networking']['hostname']}.local.${facts['networking']['domain']}",
      location            => '/status/nginx_status',
      location_cfg_append => $default_status_locations,
    }

    case $opcodecache {
      default: {
        fail("${opcodecache} is not supported")
      }
      'apc': {
        ::nginx::resource::location { "${facts['networking']['fqdn']}-02":
          ensure              => present,
          vhost               => "${facts['networking']['hostname']}.local.${facts['networking']['domain']}",
          location            => '/status/apcu',
          location_alias      => '/usr/share/apcu-panel',
          location_cfg_append => {
            'include'       => '/etc/nginx/fastcgi_params',
            'fastcgi_pass'  => '127.0.0.1:9001',
            'fastcgi_param' => 'SCRIPT_FILENAME /usr/share/apcu-panel/index.php',
            'allow'         => [
              '127.0.0.1',
              $facts['networking']['ip'],
            ],
            'deny'          => 'all',
          },
        }
      }

      'xcache': {
        ::nginx::resource::location { "${facts['networking']['fqdn']}-02":
          ensure         => present,
          vhost          => "${facts['networking']['hostname']}.local.${facts['networking']['domain']}",
          location       => '/status/xcache',
          location_alias => '/usr/share/xcache',
        }

        ::nginx::resource::location { "${facts['networking']['fqdn']}-03":
          ensure              => present,
          vhost               => "${facts['networking']['hostname']}.local.${facts['networking']['domain']}",
          location            => ' ~ ^/status/xcache(.+\\.php)$',
          location_alias      => '/usr/share/xcache/\$1',
          location_cfg_append => {
            'include'       => '/etc/nginx/fastcgi_params',
            'fastcgi_pass'  => '127.0.0.1:9001',
            'fastcgi_param' => 'SCRIPT_FILENAME \$request_filename',
            'allow'         => [
              '127.0.0.1',
              $facts['networking']['ip'],
            ],
            'deny'          => 'all',
          },
        }
      }
    }

    # TODO
    # Currently nginx pam auth doesn't seems to be easy.
    # Will try for next time.
    ::nginx::resource::vhost { "${facts['networking']['hostname']}.local.${facts['networking']['domain']}":
      listen_port => 80,
      www_root    => '/var/www/html',
      server_name => ["${facts['networking']['hostname']}.local.${facts['networking']['domain']}"],
    }
  }

  # Host entry for php vhost
  host { "${facts['networking']['hostname']}.local.${facts['networking']['domain']}":
    ip           => $facts['networking']['ip'],
    host_aliases => [ "${facts['networking']['hostname']}.local" ],
  }

  # script to check that code status
  file { "${docroot}/index.php":
    ensure  => file,
    content => template('profile/index-html.erb'),
  }

}
