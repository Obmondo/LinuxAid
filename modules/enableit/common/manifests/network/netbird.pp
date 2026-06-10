# @summary Class for managing Netbird Agent
#
# @param setup_key The setup key used for authentication.
#
# @param enable Boolean to enable or disable the Netbird agent.
#
# @param noop_value Optional boolean to enable no-operation mode.
#
# @param server The HTTPS URL of the Netbird server. Defaults to 'https://netbird.obmondo.com:443'.
#
# @param version
#   The Netbird version to install. The default is the type Eit_types::Version.
#   Link to netbird client releases page: https://github.com/netbirdio/netbird/releases
#
# @example Valid Netbird client version  
#   version = "0.59.3"
#
# @param install_method The method to install Netbird. The default is to download via their GitHub repo releases.
#
# @param wireguard_port
#   Optional UDP port to allow for NetBird mesh WireGuard inbound (default 51820). Set to undef in Hiera (e.g. `~`)
#   to skip the mesh firewall rule when direct mesh/WG ingress is not required or policy forbids opening it.
#   If set, do not duplicate the same port via common::network::wireguard::tunnels for NetBird-owned interfaces; see profile::network::netbird.
#
# @groups authentication setup_key, enable, noop_value.
#
# @groups server_details server, version, install_method.
#
class common::network::netbird (
  Boolean                  $enable,
  Stdlib::HTTPSUrl         $server,
  Eit_types::Version       $version,
  String                   $setup_key,
  Enum['package', 'repo']  $install_method,
  Eit_types::Noop_Value    $noop_value =  undef,
  Optional[Stdlib::Port]   $wireguard_port = 51820,
) {
  include profile::network::netbird
}
