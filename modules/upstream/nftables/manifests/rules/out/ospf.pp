# manage out ospf
class nftables::rules::out::ospf {
  nftables::rule {
    'default_out-ospf':
      content => 'ip daddr { 224.0.0.5, 224.0.0.6 } meta l4proto 89 accept',
  }
}
