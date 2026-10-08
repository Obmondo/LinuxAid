#
# @summary manage out ospf3
#
# @param oifname optional list of outgoing interfaces to filter on
#
class nftables::rules::out::ospf3 (
  Array[String[1]] $oifname = [],
) {
  if empty($oifname) {
    $_oifname = ''
  } else {
    $oifdata = $oifname.map |String[1] $interface| { "\"${interface}\"" }.join(', ')
    $_oifname = "oifname { ${oifdata} } "
  }
  nftables::rule { 'default_out-ospf3':
    content => "${_oifname}ip6 saddr fe80::/64 ip6 daddr { ff02::5, ff02::6 } meta l4proto 89 accept",
  }
}
