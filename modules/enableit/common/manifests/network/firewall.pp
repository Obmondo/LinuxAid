# @summary Class for managing the common::network::firewall configuration
#
# @param manage Whether to manage the firewall. Defaults to false.
#
# @param enable Enable the firewall. Defaults to true.
#
# @param enable_ipv6 Enable IPv6 support. Defaults to true.
#
# @param enable_forwarding Enable forwarding rules. Defaults to false.
#
# @param drop_all Drop all traffic by default. Defaults to true.
#
# @param drop_action Action to take for dropped packets. Defaults to 'drop'.
#
# @param allow_docker Allow Docker traffic. Defaults to false.
#
# @param allow_k8s Allow Kubernetes traffic. Defaults to false.
#
# @param allow_azure Allow Azure traffic. Defaults to false.
#
# @param allow_netbird Allow Netbird traffic. Defaults to lookup('common::network::netbird::enable', Boolean, undef, false).
#
# @param block_bogons Block bogon IP addresses. Defaults to false.
#
# @param block_mdns Block mDNS traffic. Defaults to true.
#
# @param block_kaspersky_sccc Block Kaspersky SCCC traffic. Defaults to true.
#
# @param block_hasp_lm Block Hasp LM traffic. Defaults to true.
#
# @param block_dhcp_broadcast Block DHCP broadcast traffic. Defaults to true.
#
# @param block_netbios_broadcast Block NetBIOS broadcast traffic. Defaults to true.
#
# @param rules Custom firewall rules. Defaults to {}.
#
class common::network::firewall (
  Boolean             $manage            = false,
  Boolean             $enable            = true,
  Boolean             $enable_ipv6       = true,
  Boolean             $enable_forwarding = false,
  Boolean             $drop_all          = true,
  Std_fw::Action      $drop_action       = 'drop',
  Boolean             $allow_docker      = false,
  Boolean             $allow_k8s         = false,
  Boolean             $allow_azure       = false,
  Boolean             $allow_netbird     = lookup('common::network::netbird::enable', Boolean, undef, false),

  Boolean             $block_bogons            = false,
  Boolean             $block_mdns              = true,
  Boolean             $block_kaspersky_sccc    = true,
  Boolean             $block_hasp_lm           = true,
  Boolean             $block_dhcp_broadcast    = true,
  Boolean             $block_netbios_broadcast = true,

  Eit_types::Firewall $rules = {},
) {

  if $manage {
    '::profile::network::firewall'.contain
  }

}
