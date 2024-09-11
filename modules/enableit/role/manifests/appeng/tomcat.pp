# Tomcat role
class role::appeng::tomcat (
  Enum['6', '7']           $version     = '7',
  Enum['apache', 'nginx'] $http_server = 'apache',
) inherits role::web::java {

  #Check combination of $java_version and $version (tomcat version is valid for this OS)
  class { '::profile::tomcat':
    version     => $version,
    http_server => $http_server,
  }
}
