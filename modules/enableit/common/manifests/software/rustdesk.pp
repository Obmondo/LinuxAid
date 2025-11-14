# @summary Class for managing the Rustdesk software
#
# @param client_enable Boolean parameter to control management of the Rustdesk. Defaults to false.
#
# @param server_enable Boolean parameter to enable or disable the Rustdesk. Defaults to false.
#
class common::software::rustdesk (
  Boolean            $client_enable       = false,
  Boolean            $server_enable       = false,
) {
  if $client_enable {
    class { 'rustdesk::client':
      enable     => $client_enable,
    }
  }

  if $server_enable {
    class { 'rustdesk::server':
      enable     => $server_enable,
    }
  }
}
