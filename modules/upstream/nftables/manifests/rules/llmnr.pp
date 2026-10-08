#
# @summary allow incoming Link-Local Multicast Name Resolution
#
# @param ipv4 Allow LLMNR over IPv4
# @param ipv6 Allow LLMNR over IPv6
# @param iifname optional list of incoming interfaces to filter on
#
# @author Tim Meusel <tim@bastelfreak.de>
#
# @see https://datatracker.ietf.org/doc/html/rfc4795
#
class nftables::rules::llmnr (
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
    nftables::rule { 'default_in-llmnr_v4':
      content => "${_iifname}ip daddr 224.0.0.252 udp dport 5355 accept comment \"allow LLMNR\"",
    }
  }
  if $ipv6 {
    nftables::rule { 'default_in-llmnr_v6':
      content => "${_iifname}ip6 daddr ff02::1:3 udp dport 5355 accept comment \"allow LLMNR\"",
    }
  }
}
