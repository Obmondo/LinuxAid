# @summary manage in wireguard
# @param ports wiregueard port
class nftables::rules::wireguard (
  Array[Stdlib::Port,1] $ports = [51820],
) {
  nftables::rule {
    'default_in-wireguard':
      content => "udp dport {${join($ports,', ')}} accept",
  }
}
