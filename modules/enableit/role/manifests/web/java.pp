
# @summary Class for managing the Java web role
#
# @param version The Java version to use. Defaults to 7.
#
# @groups java version
#
class role::web::java (
  Enum[6,7] $version = 7,
) inherits role::web {

  class { '::profile::web::java':
    version => $version,
    edition => 'openjdk',
  }

  class { '::role::appeng::tomcat':
    version     => $version,
    http_server => 'apache',
  }
}
