# manage out dhcp
class nftables::rules::out::dhcp {
  nftables::rule {
    'default_out-dhcpc':
      content => 'udp sport {67, 68} udp dport {67, 68} accept';
  }
}
