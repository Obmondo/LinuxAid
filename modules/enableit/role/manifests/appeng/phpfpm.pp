
# @summary Class for managing the PHP-FPM role
#
# @param ssl Enable SSL support. Defaults to false.
#
# @param ssl_cert The path to the SSL certificate file. Defaults to undef.
#
# @param ssl_key The path to the SSL key file. Defaults to undef.
#
# @param mysql Enable MySQL support. Defaults to false.
#
# @param mssql Enable MS SQL support. Defaults to false.
#
# @param catch_workers_output Catch the output of the PHP-FPM workers. Defaults to false.
#
# @param manage_webserver Manage the web server configuration. Defaults to true.
#
# @param opcodecache The opcode cache mechanism to use. Defaults to 'apc'.
#
# @param modules A hash of modules to be enabled. Defaults to an empty hash.
#
# @param version The version of PHP to install. Defaults to undef.
#
# @param memory_limit The memory limit for PHP-FPM. Defaults to undef.
#
# @param http_cfg_prepend Additional HTTP configuration to prepend. Defaults to an empty hash.
#
# @param max_children The maximum number of child processes. Defaults to 128.
#
# @param start_servers The number of child processes created on startup. Defaults to 64.
#
# @param min_spare_servers The minimum number of idle child processes. Defaults to 64.
#
# @param max_spare_servers The maximum number of idle child processes. Defaults to 100.
#
# @param virtualhosts A hash of virtual host configurations. Defaults to an empty hash.
#
class role::appeng::phpfpm (
  Boolean                             $ssl                  = false,
  Optional[Sensitive[String]]         $ssl_cert             = undef,
  Optional[Sensitive[String]]         $ssl_key              = undef,
  Boolean                             $mysql                = false,
  Boolean                             $mssql                = false,
  Boolean                             $catch_workers_output = false,
  Boolean                             $manage_webserver     = true,
  Enum['opcache', 'xcache', 'apc']  $opcodecache          = 'apc',
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
