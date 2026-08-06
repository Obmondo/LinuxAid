
# @summary Class for managing the Appeng Wildfly role
#
class role::appeng::wildfly () inherits role::web::java {

  class { '::profile::appeng::wildfly':
    version     => '8.2.0',
    http_server => 'apache',
  }
}
