#
# @summary manage in ospf3
#
# @param iifname optional list of incoming interfaces to allow traffic
#
class nftables::rules::ospf3 (
  Array[String[1]] $iifname = [],
) {
  if empty($iifname) {
    $_iifname = ''
  } else {
    $iifdata = $iifname.map |String[1] $interface| { "\"${interface}\"" }.join(', ')
    $_iifname = "iifname { ${iifdata} } "
  }
  nftables::rule { 'default_in-ospf3':
    content => "${_iifname}ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto 89 accept",
  }
}
