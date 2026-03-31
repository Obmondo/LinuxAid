# DHCP ignored subnet configuration
type Eit_types::Network::Dhcp::Ignoredsubnet = Struct[{
  'network' => String[1],
  'mask'    => String[1],
}]
