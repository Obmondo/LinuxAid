
# @summary Class for managing the Tomcat role
#
# @param version The version of Tomcat to install. Defaults to '7'.
#
# @groups server version
#
class role::appeng::tomcat (
  Enum['6', '7'] $version = '7',
) inherits role::web::java {

  # Check combination of $java_version and $version (tomcat version is valid for this OS)
  class { '::profile::appeng::tomcat':
    version     => $version,
    http_server => 'apache',
  }
}
