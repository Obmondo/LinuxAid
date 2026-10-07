# @summary Allow DHCPv6 requests out of a host
class nftables::rules::out::dhcpv6_client {
  nftables::rule {
    'default_out-dhcpv6_client':
      content => 'ip6 saddr fe80::/10 udp sport 546 udp dport 547 accept',
  }
}
