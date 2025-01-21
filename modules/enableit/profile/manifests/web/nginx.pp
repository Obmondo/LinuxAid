# Nginx Profile
class profile::web::nginx (
  Boolean                    $ssl              = $role::web::nginx::ssl,
  Boolean                    $http             = $role::web::nginx::http,
  Boolean                    $manage_repo      = $role::web::nginx::manage_repo,
  Hash                       $cfg_prepend      = $role::web::nginx::cfg_prepend,
  Hash                       $http_cfg_prepend = $role::web::nginx::http_cfg_prepend,
  Array                      $modules          = $role::web::nginx::modules,
  Hash                       $extra_cfg_option = $role::web::nginx::extra_cfg_option,
  Hash                       $servers          = $role::web::nginx::servers,
  String                     $module_directory = '/usr/lib64/nginx/modules',
  Stdlib::Port               $monitor_port     = $role::web::nginx::monitor_port,
  Enum['nginx', 'passenger'] $package_source   = $role::web::nginx::package_source,
) {

  # Firewall Rule
  firewall_multi { '000 allow http request':
    dport => [
    if $ssl { 443 },
    80,
    ].delete_undef_values,
    proto => 'tcp',
    jump  => 'accept',
  }

  $_nginx_cfg_prepend = $cfg_prepend + Hash(['load_module', $modules.map |$x| {
    # Prepend module directory to module name if not an absolute path
    ($x =~ /^\//) ? {
      false => "${module_directory}/ngx_${x}_module.so",
      true  => $x,
    }
  }])

  common::services::systemd { 'nginx.service' :
    ensure   => true,
    override => true,
    service  => {
      'RuntimeDirectory' => 'nginx',
    },
  }

  class { '::nginx':
    manage_repo          => $manage_repo,
    nginx_cfg_prepend    => $_nginx_cfg_prepend,
    http_cfg_prepend     => $http_cfg_prepend,
    log_format           => {
      'custom_access_log' => '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent $request_time "$http_referer" "$http_user_agent" "$http_x_forwarded_for"' #lint:ignore:140chars
    },
    http_format_log      => 'custom_access_log',
    *                    => $extra_cfg_option,
    notify               => Common::Services::Systemd['nginx.service'],
    purge_passenger_repo => false,
    package_source       => $package_source,
  }

  # If selinux manage is true, we need selinux port to added under port list
  if $facts.dig('selinux') {
    selinux::port { 'allow-nginx-monitoring' :
      seltype  => 'http_port_t',
      protocol => 'tcp',
      port     => $monitor_port,
    }
  }

  file { [
    '/var/www',
    '/var/www/html'
  ] :
    ensure => directory,
  }

  # vhost for nginx status and diamond collector
  ::nginx::resource::server { 'znginx' :
    listen_port => $monitor_port,
    www_root    => '/var/www/html',
    server_name => [ "www.znginx.${facts['networking']['hostname']}", 'znginx' ],
    access_log  => 'off',
  }

  $status_locations  = {
    'access_log' => '/var/log/nginx/znginx.log',
    'allow'      => [ '127.0.0.1', $facts['networking']['ip'] ],
    'deny'       => 'all',
  }

  ::nginx::resource::location { 'znginx' :
    ensure              => present,
    stub_status         => true,
    server              => 'znginx',
    location            => '/nginx_status',
    location_cfg_append => $status_locations,
  }

  host { "znginx.${facts['networking']['hostname']}":
    ip           => '127.0.0.1',
    host_aliases => [ "www.znginx.${facts['networking']['hostname']}", 'znginx' ],
  }

  file { '/var/www/html/index.html':
    ensure  => present,
    content => 'You are in the wrong place',
    require => File['/var/www/html'],
  }

  file { '/var/www/html/index.nginx-debian.html':
    ensure => absent,
  }

  $servers.each |$k, $vs| {
    nginx::resource::server { $k:
      * => $vs,
    }
  }
}
