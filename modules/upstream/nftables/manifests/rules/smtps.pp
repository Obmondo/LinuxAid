# manage in smtps
class nftables::rules::smtps {
  nftables::rule {
    'default_in-smtps':
      content => 'tcp dport 465 accept',
  }
}
