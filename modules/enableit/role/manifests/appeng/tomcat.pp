
# @summary Class for managing the Tomcat role
#
# @param version The version of Tomcat to install. Defaults to '7'.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
# @groups server version, http_server
#
class role::appeng::tomcat (
  Enum['6', '7']           $version     = '7',
  Enum['apache', 'nginx'] $http_server = 'apache',
) inherits role::web::java {

  # Check combination of $java_version and $version (tomcat version is valid for this OS)
  class { '::profile::tomcat':
    version     => $version,
    http_server => $http_server,
  }
}
