# Firewall
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
