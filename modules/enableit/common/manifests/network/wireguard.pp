# @summary Class for managing Wireguard network configuration
#
# @param enable Whether to enable Wireguard. Defaults to true.
#
# @param tunnels Hash of tunnel configurations. Defaults to an empty hash.
#
class common::network::wireguard (
  Boolean $enable   = true,
  Hash    $tunnels  = {},
) {
  if $enable and !empty($tunnels) {
    include 'profile::network::wireguard'
    include 'common::monitor::exporter::wireguard'
  }
}
