
# @summary Class for managing the Razor provisioning role
#
# @param manage_postgres Whether to manage PostgreSQL. Defaults to false.
#
# @param db_server The database server. Defaults to 'localhost'.
#
# @param db_name The name of the database. Defaults to 'razor_prd'.
#
# @param db_user The database user.
#
# @param db_password The password for the database user.
#
# @param dhcp_domain The DHCP domain.
#
# @param dhcp_start The starting IP address for DHCP.
#
# @param dhcp_end The ending IP address for DHCP.
#
# @param dhcp_route The DHCP route IP address.
#
# @param dhcp_dns The DNS server IP addresses. Defaults to $common::system::dns::nameservers.
#
# @param manage_tftpd Whether to manage TFTP daemon. Defaults to false.
#
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
