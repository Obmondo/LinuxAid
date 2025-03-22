
# @summary Class for managing the Java web role
#
# @param version The Java version to use. Defaults to 7.
#
# @param edition The edition of Java to use. Defaults to 'openjdk'.
#
# @param variant The application server variant. Defaults to '::role::appeng::tomcat'.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
class role::web::java (
  Enum[6,7] $version      = 7,
  Enum['openjdk', 'oracle'] $edition = 'openjdk',
  Enum['::role::appeng::tomcat', '::role::appeng::wildfly']    $variant = '::role::appeng::tomcat',
  Enum['apache', 'nginx'] $http_server  = 'apache',
) inherits role::web {

  class { '::profile::java':
    version => $version,
    edition => $edition,
  }

  case $variant {
    '::role::appeng::tomcat' : {
      class { '::role::appeng::tomcat':
        version     => $version,
        http_server => $http_server
      }
    }
    '::role::appeng::wildfly' : {
      class { '::role::appeng::wildfly':
        version     => $version,
        http_server => $http_server
      }
    }
    default : {
      fail("${variant} is not supported")
    }
  }
}
