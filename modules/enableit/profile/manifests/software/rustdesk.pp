# @summary Class for managing the Rustdesk software
#
# @param client_enable Boolean parameter to enable or disable the Rustdesk client. Defaults to false.
#
# @param client_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
# @param server_enable Boolean parameter to enable or disable the Rustdesk server. Defaults to false.
#
# @param server_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
class profile::software::rustdesk (
  Boolean             $client_enable             = $common::software::rustdesk::client_enable,
  Array[String]       $client_extra_dependencies = $common::software::rustdesk::client_extra_dependencies,

  Boolean             $server_enable             = $common::software::rustdesk::server_enable,
  Array[String]       $server_extra_dependencies = $common::software::rustdesk::server_extra_dependencies,
) {
  class { 'rustdesk':
    client_enable             => $client_enable,
    client_extra_dependencies => $client_extra_dependencies,

    server_enable             => $server_enable,
    server_extra_dependencies => $server_extra_dependencies,
  }
}
