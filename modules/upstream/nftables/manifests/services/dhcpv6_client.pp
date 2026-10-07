# @summary Allow in and outbound traffic for DHCPv6 server
class nftables::services::dhcpv6_client inherits nftables {
  if $nftables::out_all {
    fail('All outgoing traffic is allowed, you might want to use only nftables::rules::dhcpv6_client')
  }

  include nftables::rules::dhcpv6_client
  include nftables::rules::out::dhcpv6_client
}
