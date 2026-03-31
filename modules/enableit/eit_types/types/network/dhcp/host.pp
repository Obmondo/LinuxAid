# DHCP host reservation configuration
type Eit_types::Network::Dhcp::Host = Hash[String, Struct[{
  'mac'               => Eit_types::MAC,
  'ip'                => Optional[Stdlib::IP::Address],
  'ddns_hostname'     => Optional[String[1]],
  'options'           => Optional[Hash],
  'comment'           => Optional[String[1]],
  'ignored'           => Optional[Boolean],
  'default_lease_time' => Optional[Integer],
  'max_lease_time'    => Optional[Integer],
  'ipxe_filename'     => Optional[String[1]],
  'ipxe_bootstrap'    => Optional[String[1]],
  'filename'          => Optional[String[1]],
  'on_commit'         => Optional[Array[String[1]]],
  'on_release'        => Optional[Array[String[1]]],
  'on_expiry'         => Optional[Array[String[1]]],
}]]
