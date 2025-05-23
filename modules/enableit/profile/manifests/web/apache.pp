#generic apache setup
class profile::web::apache (
  Boolean                              $https   = $role::web::apache::https,
  Boolean                              $http    = $role::web::apache::http,
  Optional[Enum['default','insecure']] $ciphers = $role::web::apache::ciphers,
  Array                                $modules = $role::web::apache::modules,

  Eit_types::Web::Apache::Vhosts     $vhosts  = $role::web::apache::vhosts,
  Array[Eit_types::Monitor::Domains] $domains = $role::web::apache::domains,
) {

  $listen_ports = [
    if $https { 443 },
    if $http { 80 },
    $vhosts.map |$_, $_params| {
      $_params['port']
    },
  ].flatten.delete_undef_values.sort.unique

  # Firewall
  firewall_multi { '000 allow http request':
    dport => $listen_ports,
    proto => 'tcp',
    jump  => 'accept',
  }

  $default_modules = [
    'status',
    'proxy',
  ]

  $_modules = [ $default_modules + $modules ].flatten.unique

  # which user runs apache
  case $facts['os']['family'] {
    'RedHat' : { $apache_user = 'apache' }
    'Debian' : { $apache_user = 'www-data' }
    default  : { $apache_user = 'daemon' }
  }

  class { 'apache':
    mpm_module        => if 'php' in $_modules { 'prefork' },
    default_vhost     => $http,
    default_ssl_vhost => $https,
  }

  # NOTE: apache puppet module has some sane default for some modules, like php
  # It can configure required libphp depending on the osversion, but in some case
  # we just want the module to be loaded, like mod_headers
  $_modules.each | $mod | {
    if $mod == 'proxy_uwsgi' {
      case $facts['os']['family'] {
        'RedHat': { package { 'mod_proxy_uwsgi' : } }
        'Debian': { package { 'libapache2-mod-proxy-uwsgi' : } }
        default: { fail("Not supported ${facts['os']['family']} ") }
      }
    }

    if $mod == 'proxy_fcgi' {
      # [error] (13)Permission denied: mod_fcgid: couldn't bind unix domain socket /etc/httpd/logs/fcgidsock/628.61
      # We need this variables to be present, this variable is default in package

      file { '/var/run/mod_fcgid/':
        ensure => 'directory',
        owner  => $apache_user,
        group  => $apache_user,
        mode   => '0755',
        notify => Class['::apache::mod::fcgid'],
      }

      class { '::apache::mod::fcgid':
        options => {
          'FcgidIPCDir'           => '/var/run/mod_fcgid',
          'FcgidProcessTableFile' => '/var/run/mod_fcgid/fcgid_shm',
        },
      }

      # Let proxy_fcgi mod handle the file by puppet and not by package
      ::apache::mod { 'proxy_fcgi' : }
    }

    # Setup apache modules
    class { "::apache::mod::${mod}" : }
  }

  # Setup customers virtualhosts
  unwrap($vhosts).each |$vhost_name, $params| {
    if $params['ssl'] {
      file {
        "/etc/ssl/private/${vhost_name}":
          ensure => directory,
          owner  => $apache_user,
          mode   => '0700',
        ;
        "/etc/ssl/private/${vhost_name}/cert.pem":
          content => $params['ssl_cert'].node_encrypt::secret,
          owner   => $apache_user,
          mode    => '0600',
          notify  => Service['httpd'],
        ;
        "/etc/ssl/private/${vhost_name}/cert.key":
          content => $params['ssl_key'].node_encrypt::secret,
          owner   => $apache_user,
          mode    => '0600',
          notify  => Service['httpd'],
        ;
      }

      if ! $params['domains'].empty {
        $params['domains'].map |$domain| {
          monitor::domains { "${domain}_${params['port']}":
            domain => "https://${domain}:${params['port']}",
          }
        }
      } elsif ! $domains.empty {
        $domains.map |$domain| {
          monitor::domains { $domain:
            domain => "https://${domain}",
          }
        }
      } else {
        $domain = extract_common_name($params['ssl_cert'])
        monitor::domains { $domain:
          domain => "https://${domain}",
        }
      }
    }

    apache::vhost { $vhost_name:
      ssl             => $params['ssl'],
      port            => $params['port'],
      ssl_cert        => if $params['ssl'] { "/etc/ssl/private/${vhost_name}/cert.pem" },
      ssl_key         => if $params['ssl'] { "/etc/ssl/private/${vhost_name}/cert.key" },
      docroot         => $params['docroot'],
      manage_docroot  => false,
      override        => ['ALL'],
      redirect_dest   => $params['redirect_dest'],
      redirect_status => $params['redirect_status'],
      directories     => $params['directories'],
      serveraliases   => $params['serveraliases'],
      aliases         => $params['aliases'],
      proxy_pass      => $params['proxy_pass'],
    }
  }

  #default ssl setup
  case $ciphers {
    'insecure': {
      $cipher   ='HIGH:MEDIUM:!aNULL:!MD5'
      $protocol = [ 'all', '-SSLv2' ]
    }
    default: {
      $cipher   = 'HIGH:MEDIUM:!aNULL:!MD5:!RC4:!3DES'
      $protocol = [ 'all', '-SSLv2', '-SSLv3' ]
    }
  }

  class { 'apache::mod::ssl':
    ssl_cipher   => $cipher,
    ssl_protocol => $protocol,
  }
}
