#
# @summary allow incoming multicast DNS
#
# @param ipv4
#   Allow mdns over IPv4
# @param ipv6
#   Allow mdns over IPv6
# @param iifname name for incoming interfaces to filter
#
class nftables::rules::mdns (
  Boolean $ipv4 = true,
  Boolean $ipv6 = true,
  Array[String[1]] $iifname = [],
) {
  if empty($iifname) {
    $_iifname = ''
  } else {
    $iifdata = $iifname.map |String[1] $interface| { "\"${interface}\"" }.join(', ')
    $_iifname = "iifname { ${iifdata} } "
  }
  if $ipv4 {
    nftables::rule { 'default_in-mdns_v4':
      content => "${_iifname}ip daddr 224.0.0.251 udp dport 5353 accept",
    }
  }
  if $ipv6 {
    nftables::rule { 'default_in-mdns_v6':
      content => "${_iifname}ip6 daddr ff02::fb udp dport 5353 accept",
    }
  }
}
