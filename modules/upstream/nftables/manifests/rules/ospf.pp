# manage in ospf
class nftables::rules::ospf {
  nftables::rule {
    'default_in-ospf':
      content => 'ip daddr { 224.0.0.5, 224.0.0.6 } meta l4proto 89 accept',
  }
}
