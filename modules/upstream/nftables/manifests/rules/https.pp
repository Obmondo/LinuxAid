# manage in https
class nftables::rules::https {
  nftables::rule {
    'default_in-https':
      content => 'tcp dport 443 accept',
  }
}
