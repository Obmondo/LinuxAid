# @summary allow outgoing smtp
class nftables::rules::out::smtp {
  nftables::rule {
    'default_out-smtp':
      content => 'tcp dport 25 accept',
  }
}
