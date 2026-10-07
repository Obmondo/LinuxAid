# @summary allow outgoing hkp connections to gpg keyservers
class nftables::rules::out::hkp {
  nftables::rule { 'default_out-hkp':
    content => 'tcp dport 11371 accept',
  }
}
