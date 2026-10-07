# @summary allow outgoing rsync connections
class nftables::rules::out::rsync {
  nftables::rule {
    'default_out-rsync':
      content => 'tcp dport 873 accept',
  }
}
