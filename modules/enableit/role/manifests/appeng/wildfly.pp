
# @summary Class for managing the Appeng Wildfly role
#
# @param version The version of Wildfly to use. Defaults to '8.2.0'.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
# @groups server http_server, version
#
class role::appeng::wildfly (
  Enum['8.2.0', '9.0.0'] $version     = '8.2.0',
  Enum['apache'] $http_server         = 'apache',
) inherits role::web::java {

  class { '::profile::wildfly':
    version     => $version,
    http_server => $http_server,
  }
}
