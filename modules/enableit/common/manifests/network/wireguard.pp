# @summary Class for managing Wireguard network configuration
#
# @param enable Whether to enable Wireguard. Defaults to true.
#
# @param tunnels Hash of tunnel configurations. Defaults to an empty hash.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class common::network::wireguard (
  Boolean $enable   = true,
  Hash    $tunnels  = {},
  Eit_types::Encrypt::Params  $encrypt_params  = ['tunnels.*.private_key'],
) {
  if $enable and !empty($tunnels) {
    include 'profile::network::wireguard'
    include 'common::monitor::exporter::wireguard'
  }
}
