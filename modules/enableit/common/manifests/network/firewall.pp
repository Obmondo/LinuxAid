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
# @param block_bogons Block bogon IP addresses. Defaults to false.
#
# @param rules Custom firewall rules. Defaults to {}.
#
# @groups management manage, enable, enable_ipv6, enable_forwarding, drop_all, drop_action
#
# @groups allow_traffic allow_docker, allow_k8s, allow_azure
#
# @groups block_traffic block_bogons
#
# @groups custom_rules rules
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
  Boolean             $block_bogons      = false,

  Eit_types::Firewall $rules = {},
) {

  if $manage {
    '::profile::network::firewall'.contain
  }

}
