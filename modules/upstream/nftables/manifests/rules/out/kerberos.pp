# @summary allows outbound access for kerberos
class nftables::rules::out::kerberos {
  nftables::rule {
    'default_out-kerberos_udp':
      content => 'udp dport 88 accept';
    'default_out-kerberos_tcp':
      content => 'tcp dport 88 accept';
  }
}
