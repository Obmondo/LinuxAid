# Wireguard
class common::network::wireguard (
  Boolean $enable  = true,
  Hash    $tunnels = {},
) {

  if $enable and !empty($tunnels) {
    include 'profile::network::wireguard'
    include 'common::monitor::exporter::wireguard'
  }
}
