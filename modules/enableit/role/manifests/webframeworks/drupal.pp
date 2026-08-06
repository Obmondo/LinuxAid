
# @summary Class: role::webframeworks::drupal  Optimized Drupal server setup including Latest stable Drupal version
#
# @param url The URL for the Drupal application.
#
# @param php The PHP backend to use. Defaults to '::role::appeng::phpfpm'.
#
# @param db The database backend to use. Defaults to '::role::db::mysql'.
#
# @param http_server The HTTP server to use. Defaults to '::role::web::apache'.
#
# @groups application url, php, http_server
#
# @groups database db
# 
class role::webframeworks::drupal (
  String $url,
  Enum['::role::appeng::phpfpm', '::role::appeng::mod_php'] $php           = '::role::appeng::phpfpm',
  Enum['::role::db::mysql', '::role::db::pgsql'] $db            = '::role::db::mysql',
  Enum['::role::web::apache'] $http_server   = '::role::web::apache'
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
    ensure => false,
  }

  class { '::profile::webframeworks::drupal':
    url         => $url,
    php         => $php,
    dbdriver    => $dbdriver,
    http_server => $http_server,
    password    => 'drupal_xyz',
  }
}
