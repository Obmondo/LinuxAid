# @summary allow incoming rsync connections
class nftables::rules::rsync {
  nftables::rule {
    'default_in-rsync':
      content => 'tcp dport 873 accept',
  }
}
