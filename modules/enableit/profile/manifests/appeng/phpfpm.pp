# PHPFPm profile
class profile::appeng::phpfpm (
  Boolean                             $ssl                  = false,
  Optional[String]                    $ssl_cert             = $::role::appeng::phpfpm::ssl_cert,
  Optional[String]                    $ssl_key              = $::role::appeng::phpfpm::ssl_key,
  Boolean                             $mysql                = false,
  Boolean                             $mssql                = false,
  Boolean                             $catch_workers_output = false,
  Boolean                             $manage_webserver     = true,
  Enum[ 'opcache', 'xcache', 'apc' ]  $opcodecache          = 'apc',
  Hash[Eit_types::SimpleString, Hash] $modules              = {},
  Optional[Eit_types::Version]        $version              = undef,
  Optional[Eit_types::Capacity]       $memory_limit         = undef,
  Optional[Hash]                      $http_cfg_prepend     = {},
  Integer[1,512]                      $max_children         = 128,
  Integer[1,512]                      $start_servers        = 64,
  Integer[1,512]                      $min_spare_servers    = 64,
  Integer[1,512]                      $max_spare_servers    = 100,
  Hash[String,Struct[{
    ensure        => Boolean,
    document_root => Stdlib::Unixpath,
    ssl_key       => Optional[String],
    ssl_cert      => Optional[String],
  }]]                                $virtualhosts         = {},
) {

  # Setup FPM
  class { '::profile::php' :
    ssl             => $ssl,
    phpfpm          => true,
    version         => $version,
    opcodecache     => $opcodecache,
    mysql           => $mysql,
    mssql           => $mssql,
    memory_limit    => $memory_limit,
    modules         => $modules,
    phpfpm_settings => {
      'listen'               => '127.0.0.1:9001',
      'catch_workers_output' => to_yesno($catch_workers_output),
      'pm_max_children'      => $max_children,
      'pm_start_servers'     => $start_servers,
      'pm_min_spare_servers' => $min_spare_servers,
      'pm_max_spare_servers' => $max_spare_servers,
    },
  }

  # Setup Http Server
  if $manage_webserver {
    class { '::profile::web::nginx':
      http_cfg_prepend => $http_cfg_prepend,
      ssl              => $ssl,
      http             => true,
      manage_repo      => false,
      cfg_prepend      => {},
      modules          => [],
      extra_cfg_option => {},
      servers          => {},
      monitor_port     => 63080,
      package_source   => 'nginx',
    }

    nginx::resource::location { 'fpm_status' :
      ensure              => present,
      stub_status         => true,
      server              => 'znginx',
      location            => '~ ^/(fpm_status|ping)',
      location_cfg_append => {
        'include'       => '/etc/nginx/fastcgi_params',
        'fastcgi_pass'  => '127.0.0.1:9001',
        'fastcgi_param' => 'SCRIPT_FILENAME $document_root$fastcgi_script_name',
        'allow'         => [ '127.0.0.1', $facts['networking']['ip'] ],
        'deny'          => 'all',
      },
    }

    $_virtualhost_opts_defaults = {
      ensure => true,
    }

    # Merge Locations from all the places
    $virtualhosts.each |$virtualhost, $opts| {

      if $ssl {
        file {
          default:
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0600',
          ;
          "/etc/ssl/private/${virtualhost}":
            ensure => directory,
            mode   => '0700',
          ;
          "/etc/ssl/private/${virtualhost}/cert.pem":
            content => pick($opts['ssl_cert'], $ssl_cert),
          ;
          "/etc/ssl/private/${virtualhost}/cert.key":
            content => pick($opts['ssl_key'], $ssl_key),
          ;
        }
      }

      nginx::resource::location { "${virtualhost}_php" :
        ensure             => present,
        ssl                => $ssl,
        server             => $virtualhost,
        location           => '~ \.php$',
        www_root           => $opts['document_root'],
        fastcgi            => '127.0.0.1:9001',
        fastcgi_split_path => '^(.+\.php)(/.+)$',
      }

      nginx::resource::server { $virtualhost:
        ensure            => ensure_present($opts['ensure']),
        server_name       => [$virtualhost],
        ssl               => $ssl,
        ssl_cert          => if $ssl { "/etc/ssl/private/${virtualhost}/cert.pem" },
        ssl_key           => if $ssl { "/etc/ssl/private/${virtualhost}/cert.key" },
        ssl_redirect      => $ssl,
        www_root          => $opts['document_root'],
        autoindex         => 'on',
        format_log        => 'custom_access_log',
        server_cfg_append => {
          'client_max_body_size'         => '100m',
          'fastcgi_pass_request_headers' => 'on',
          'underscores_in_headers'       => 'on',
        }
      }
    }
  }
}
