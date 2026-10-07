# @summary manage out wireguard
# @param ports specify wireguard ports
class nftables::rules::out::wireguard (
  Array[Integer,1] $ports = [51820],
) {
  nftables::rule {
    'default_out-wireguard':
      content => "udp dport {${join($ports,', ')}} accept",
  }
}
