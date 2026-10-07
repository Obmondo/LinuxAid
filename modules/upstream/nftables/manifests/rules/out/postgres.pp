# manage out postgres
class nftables::rules::out::postgres {
  nftables::rule {
    'default_out-postgres':
      content => 'tcp dport 5432 accept';
  }
}
