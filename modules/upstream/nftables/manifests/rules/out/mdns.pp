#
# @summary allow outgoing multicast DNS
#
# @param ipv4 Allow mdns over IPv4
# @param ipv6 Allow mdns over IPv6
# @param oifname optional name for outgoing interfaces
#
class nftables::rules::out::mdns (
  Boolean $ipv4 = true,
  Boolean $ipv6 = true,
  Array[String[1]] $oifname = [],
) {
  if empty($oifname) {
    $_oifname = ''
  } else {
    $oifdata = $oifname.map |String[1] $interface| { "\"${interface}\"" }.join(', ')
    $_oifname = "oifname { ${oifdata} } "
  }
  if $ipv4 {
    nftables::rule { 'default_out-mdns_v4':
      content => "${_oifname}ip daddr 224.0.0.251 udp dport 5353 accept",
    }
  }
  if $ipv6 {
    nftables::rule { 'default_out-mdns_v6':
      content => "${_oifname}ip6 daddr ff02::fb udp dport 5353 accept",
    }
  }
}
