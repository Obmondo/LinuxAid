#
# @summary allow outgoing SSDP
#
# @param ipv4 Allow SSDP over IPv4
# @param ipv6 Allow SSDP over IPv6
#
# @see https://datatracker.ietf.org/doc/html/draft-cai-ssdp-v1-03
#
class nftables::rules::out::ssdp (
  Boolean $ipv4 = true,
  Boolean $ipv6 = true,
) {
  if $ipv4 {
    nftables::rule { 'default_out-ssdp_v4':
      content => 'ip daddr 239.255.255.250 udp dport 1900 accept comment "allow outgoing SSDP"',
    }
  }
  if $ipv6 {
    nftables::rule { 'default_out-ssdp_v6':
      content => 'ip6 daddr {ff02::c, ff05::c} udp dport 1900 accept comment "allow outgoing SSDP"',
    }
  }
}
