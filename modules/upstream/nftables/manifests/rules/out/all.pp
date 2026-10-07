# allow all outbound
class nftables::rules::out::all {
  nftables::rule {
    'default_out-all':
      order   => '90',
      content => 'accept',
  }
}
