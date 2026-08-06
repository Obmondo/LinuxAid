
# 
# @summary Class for managing the Wordpress role
#
# @param url The URL of the Wordpress installation. Defaults to undef.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
# @groups server url, http_server
#
class role::webframeworks::wordpress (
  String $url = undef,
  Enum['apache', 'nginx'] $http_server = 'apache',
) inherits ::role::webframeworks {

  $php = '::role::appeng::phpfpm'
  $db = '::role::db::mysql'

  class { $php:
    http_server  => $http_server,
    mysql        => true,
    memory_limit => '512M',
  }

  class { $db: }

  class { '::profile::wordpress':
    url         => $url,
    http_server => $http_server,
    php         => $php,
    force_https => false,
    dbdriver    => regsubst($db, /::role::db::(.+)/, '\1'),
  }

  class { '::role::db::memcached':
    ensure => false,
  }
}
