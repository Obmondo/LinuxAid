# @summary allow DHCPv6 requests in to a host
class nftables::rules::dhcpv6_client {
  nftables::rule {
    'default_in-dhcpv6_client':
      content => 'ip6 saddr fe80::/10 ip6 daddr fe80::/10 udp sport 547 udp dport 546 accept',
  }
}
