# @summary allow outgoing smtp client
class nftables::rules::out::smtp_client {
  nftables::rule {
    'default_out-smtp_client':
      content => 'tcp dport {465, 587} accept',
  }
}
