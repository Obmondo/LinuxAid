
# 
# @summary Class for managing the Wordpress role
#
# @param php  The PHP implementation to use. Defaults to '::role::appeng::phpfpm'.
#
# @param url The URL of the Wordpress installation. Defaults to undef.
#
# @param memcached Whether to enable Memcached. Defaults to false.
#
# @param db The database backend to use. Defaults to '::role::db::mysql'.
#
# @param force_https Whether to enforce HTTPS. Defaults to false.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
# @param php_memory_limit The PHP memory limit. Defaults to '512M'.
#
class role::webframeworks::wordpress (
  Enum['::role::appeng::phpfpm', '::role::appeng::mod_php'] $php = '::role::appeng::phpfpm',
  String $url = undef,
  Boolean $memcached = false,
  Enum['::role::db::mysql'] $db = '::role::db::mysql',
  Boolean $force_https = false,
  Enum['apache', 'nginx'] $http_server = 'apache',
  Optional[Pattern[/[0-9]+[MG]/]] $php_memory_limit = '512M',
) inherits ::role::webframeworks {

  class { $php:
    http_server  => $http_server,
    mysql        => true,
    memory_limit => $php_memory_limit,
  }

  class { $db: }

  class { '::profile::wordpress':
    url         => $url,
    http_server => $http_server,
    php         => $php,
    force_https => $force_https,
    dbdriver    => regsubst($db, /::role::db::(.+)/, '\1'),
  }

  class { '::role::db::memcached':
    ensure => $memcached,
  }
}
