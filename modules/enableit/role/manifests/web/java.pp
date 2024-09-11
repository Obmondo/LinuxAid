# Java web role
class role::web::java (
  Enum[6,7] $version      = 7,
  Enum['openjdk', 'oracle'] $edition = 'openjdk',
  Enum['::role::appeng::tomcat', '::role::appeng::wildfly']
    $variant = '::role::appeng::tomcat',
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
