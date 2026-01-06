
# @summary Class: role::webframeworks::drupal  Optimized Drupal server setup including Latest stable Drupal version
#
# @param url The URL for the Drupal application.
#
# @param php The PHP backend to use. Defaults to '::role::appeng::phpfpm'.
#
# @param reverse_cache Enable or disable reverse caching. Defaults to true.
#
# @param memcached Enable or disable memcached. Defaults to false.
#
# @param db The database backend to use. Defaults to '::role::db::mysql'.
#
# @param http_server The HTTP server to use. Defaults to '::role::web::apache'.
#
# @param password The password for the Drupal application. Defaults to 'drupal_xyz'.
#
# @groups application url, php, http_server, password
#
# @groups cache reverse_cache, memcached
#
# @groups database db
# 
class role::webframeworks::drupal (
  String $url,
  Enum['::role::appeng::phpfpm', '::role::appeng::mod_php'] $php           = '::role::appeng::phpfpm',
  Boolean    $reverse_cache = true,
  Boolean    $memcached     = false,
  Enum['::role::db::mysql', '::role::db::pgsql'] $db            = '::role::db::mysql',
  Enum['::role::web::apache'] $http_server   = '::role::web::apache',
  String    $password      = 'drupal_xyz'
) inherits ::role::webframeworks {

  class { $php:
    http_server => $http_server,
  }

  case $db {
    '::role::db::mysql': {
      class { '::role::db::mysql': }
      $dbdriver = 'mysql'
    }
    '::role::db::pgsql': {
      class { '::role::db::pgsql': }
      $dbdriver = 'pgsql'
    }
    default: {
      fail('Unsupported DB')
    }
  }

  class { '::role::db::memcached':
    ensure => $memcached,
  }

  class { '::profile::drupal':
    url         => $url,
    php         => $php,
    dbdriver    => $dbdriver,
    http_server => $http_server,
    password    => $password,
  }
}
