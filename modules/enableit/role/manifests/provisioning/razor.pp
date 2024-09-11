# Razor
class role::provisioning::razor (
  Boolean $manage_postgres          = false,
  Eit_types::Host $db_server        = 'localhost',
  Eit_types::SimpleString $db_name  = 'razor_prd',
  Eit_types::SimpleString $db_user  = 'razor',
  Eit_types::Password $db_password,
  Eit_types::Domain $dhcp_domain,
  Eit_types::IP $dhcp_start,
  Eit_types::IP $dhcp_end,
  Eit_types::IP $dhcp_route,
  Array[Eit_types::IP, 1] $dhcp_dns = $common::system::dns::nameservers,
  Boolean $manage_tftpd             = false,
) inherits ::role {

  include profile::provisioning::razor
}
