# == Class: role::webframeworks::drupal
#
# description: Optimized Drupal server setup including Latest stable Drupal
# version
#
class role::webframeworks::drupal (
  String $url,
  Enum['::role::appeng::phpfpm', '::role::appeng::mod_php']
    $php           = '::role::appeng::phpfpm',
  Boolean
    $reverse_cache = true,
  Boolean
    $memcached     = false,
  Enum['::role::db::mysql', '::role::db::pgsql']
    $db            = '::role::db::mysql',
  Enum['::role::web::apache']
    $http_server   = '::role::web::apache',
  String
    $password      = 'drupal_xyz'
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
