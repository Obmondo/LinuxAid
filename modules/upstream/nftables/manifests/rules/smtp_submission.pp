# manage in smtp submission
class nftables::rules::smtp_submission {
  nftables::rule {
    'default_in-smtp_submission':
      content => 'tcp dport 587 accept',
  }
}
