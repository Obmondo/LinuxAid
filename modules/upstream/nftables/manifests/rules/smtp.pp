# manage in smtp
class nftables::rules::smtp {
  nftables::rule {
    'default_in-smtp':
      content => 'tcp dport 25 accept',
  }
}
