
# @summary Class for managing the Razor provisioning role
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
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups db db_password, encrypt_params
#
# @groups dhcp dhcp_domain, dhcp_start, dhcp_end, dhcp_route
#
# @encrypt_params db_password
# 
class role::provisioning::razor (
  Eit_types::Password $db_password,
  Eit_types::Domain $dhcp_domain,
  Eit_types::IP $dhcp_start,
  Eit_types::IP $dhcp_end,
  Eit_types::IP $dhcp_route,

  Eit_types::Encrypt::Params $encrypt_params = [
    'db_password',
  ]

) inherits ::role {

  include profile::provisioning::razor
}
