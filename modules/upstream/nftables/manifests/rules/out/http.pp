# manage out http
class nftables::rules::out::http {
  nftables::rule {
    'default_out-http':
      content => 'tcp dport 80 accept';
  }
}
