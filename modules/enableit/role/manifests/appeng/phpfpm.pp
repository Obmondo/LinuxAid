# PHPFPM
class role::appeng::phpfpm (
  Boolean                             $ssl                  = false,
  Optional[String]                    $ssl_cert             = undef,
  Optional[String]                    $ssl_key              = undef,
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
  }]]                                 $virtualhosts         = {},
) inherits ::role::appeng {

  confine($opcodecache == 'opcache',
    $version and $version !~ /^7/,
    "${opcodecache} is only support with PHP 7.0"
  )

  confine($ssl, !($ssl_key and $ssl_cert), 'if SSL is enabled, ssl_key and ssl_cert is required')

  class { '::profile::appeng::phpfpm' :
    ssl                  => $ssl,
    ssl_key              => $ssl_key,
    ssl_cert             => $ssl_cert,
    mysql                => $mysql,
    mssql                => $mssql,
    catch_workers_output => $catch_workers_output,
    manage_webserver     => $manage_webserver,
    opcodecache          => $opcodecache,
    modules              => $modules,
    version              => $version,
    memory_limit         => $memory_limit,
    http_cfg_prepend     => $http_cfg_prepend,
    max_children         => $max_children,
    start_servers        => $start_servers,
    min_spare_servers    => $min_spare_servers,
    max_spare_servers    => $max_spare_servers,
    virtualhosts         => $virtualhosts,
  }
}
