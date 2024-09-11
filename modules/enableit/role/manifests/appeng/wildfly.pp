# Wildfly role
class role::appeng::wildfly (
  Enum['8.2.0', '9.0.0'] $version = '8.2.0',
  Enum['apache'] $http_server                        = 'apache',
) inherits role::web::java {

  class { '::profile::wildfly':
    version     => $version,
    http_server => $http_server,
  }
}
