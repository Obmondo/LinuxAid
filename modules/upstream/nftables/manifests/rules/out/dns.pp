# @summary manage out dns
# @param dns_server specify dns_server name
class nftables::rules::out::dns (
  Array[Stdlib::IP::Address] $dns_server = [],
) {
  unless empty($dns_server) {
    $dns_server.each |$index,$dns| {
      $content = $dns ? {
        Stdlib::IP::Address::V6 => "ip6 daddr ${dns}",
        Stdlib::IP::Address::V4 => "ip daddr ${dns}",
      }
      nftables::rule { "default_out-dnstcp-${index}":
        content => "${content} tcp dport 53 accept",
      }
      nftables::rule { "default_out-dnsudp-${index}":
        content => "${content} udp dport 53 accept",
      }
    }
  } else {
    nftables::rule {
      'default_out-dnsudp':
        content => 'udp dport 53 accept';
      'default_out-dnstcp':
        content => 'tcp dport 53 accept';
    }
  }
}
