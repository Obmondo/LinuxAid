#
# @summary allow incoming webservice discovery
#
# @param ipv4 Allow ws-discovery over IPv4
# @param ipv6 Allow ws-discovery over IPv6
#
# @see https://docs.oasis-open.org/ws-dd/ns/discovery/2009/01
#
class nftables::rules::wsd (
  Boolean $ipv4 = true,
  Boolean $ipv6 = true,
) {
  if $ipv4 {
    nftables::rule { 'default_in-wsd_v4':
      content => 'ip daddr 239.255.255.250 udp dport 3702 accept comment "accept ws-discovery"',
    }
  }
  if $ipv6 {
    nftables::rule { 'default_in-wsd_v6':
      content => 'ip6 daddr ff02::c udp dport 3702 accept comment "accept ws-discovery"',
    }
  }
}
