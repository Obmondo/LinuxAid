# @summary allow multicast listener requests
class nftables::rules::out::mldv2 {
  nftables::rule { 'default_out-mld':
    content => 'ip6 daddr { ff02::16 } accept',
  }
}
