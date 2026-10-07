# @summary allow outgoing imap
class nftables::rules::out::imap {
  nftables::rule {
    'default_out-imap':
      content => 'tcp dport {143, 993} accept',
  }
}
