# Wordpress role
class role::webframeworks::wordpress (
  Enum['::role::appeng::phpfpm', '::role::appeng::mod_php'] $php = '::role::appeng::phpfpm',
  String $url                                                    = undef,
  Boolean $memcached                                             = false,
  Enum['::role::db::mysql'] $db                                  = '::role::db::mysql',
  Boolean $force_https                                           = false,
  Enum['apache', 'nginx'] $http_server                           = 'apache',
  Optional[Pattern[/[0-9]+[MG]/]] $php_memory_limit              = '512M',
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
