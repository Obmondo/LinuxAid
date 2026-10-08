# @summary manage out chrony
# @param servers single IP-Address or array of IP-addresses from NTP servers
class nftables::rules::out::chrony (
  Array[Stdlib::IP::Address] $servers = [],
) {
  if empty($servers) {
    nftables::rule {
      'default_out-chrony':
        content => 'udp dport 123 accept',
    }
  } else {
    $ipv6_servers = $servers.filter |$ip| { $ip =~ Stdlib::IP::Address::V6 }
    $ipv4_servers = $servers.filter |$ip| { $ip =~ Stdlib::IP::Address::V4 }
    unless empty($ipv6_servers) {
      nftables::rule { 'default_out-chrony_v6':
        content => "ip6 daddr {${join($ipv6_servers, ',')}} udp dport 123 accept",
      }
    }
    unless empty($ipv4_servers) {
      nftables::rule { 'default_out-chrony_v4':
        content => "ip daddr {${join($ipv4_servers, ',')}} udp dport 123 accept",
      }
    }
  }
}
