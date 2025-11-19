# @summary Class for managing the Rustdesk software
#
# @param client_enable Boolean parameter to control management of the Rustdesk. Defaults to false.
#
# @param client_version Boolean parameter to control management of the Rustdesk. Defaults to false.
#
# @param server_enable Boolean parameter to enable or disable the Rustdesk. Defaults to false.
#
# @param server_version Boolean parameter to enable or disable the Rustdesk. Defaults to false.
#
class common::software::rustdesk (
  Boolean            $client_enable       = false,
  Boolean            $client_version      = false,
  Boolean            $server_enable       = false,
  Boolean            $server_version      = false,
) {
  class { 'rustdesk':
    client_enable  => $client_enable,
    client_version => $client_version,

    server_enable  => $server_enable,
    server_version => $server_version,
  }
}
