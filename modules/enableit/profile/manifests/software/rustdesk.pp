# @summary Class for managing the Rustdesk software
#
# @param client_enable Boolean parameter to enable or disable the Rustdesk client. Defaults to false.
#
# @param client_version SemVer parameter to control Rustdesk client version. Defaults to false.
#
# @param client_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
# @param server_enable Boolean parameter to enable or disable the Rustdesk server. Defaults to false.
#
# @param server_version SemVer parameter to control Rustdesk server version. Defaults to false.
#
# @param server_extra_dependencies Array[String] parameter to install OS specific dependencies. Defaults to [].
#
class profile::software::rustdesk (
  Boolean            $client_enable             = $common::software::rustdesk::client_enable,
  SemVer             $client_version            = $common::software::rustdesk::client_version,
  Array[String]      $client_extra_dependencies = $common::software::rustdesk::client_extra_dependencies,

  Boolean            $server_enable             = $common::software::rustdesk::server_enable,
  SemVer             $server_version            = $common::software::rustdesk::server_version,
  Array[String]      $server_extra_dependencies = $common::software::rustdesk::server_extra_dependencies,
) {
  class { 'rustdesk':
    client_enable             => $client_enable,
    client_version            => $client_version,
    client_extra_dependencies => $client_extra_dependencies,

    server_enable             => $server_enable,
    server_version            => $server_version,
    server_extra_dependencies => $server_extra_dependencies,
  }
}
