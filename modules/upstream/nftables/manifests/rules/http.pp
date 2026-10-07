# manage in http
class nftables::rules::http {
  nftables::rule {
    'default_in-http':
      content => 'tcp dport 80 accept',
  }
}
