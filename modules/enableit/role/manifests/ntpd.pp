
# @summary Class for managing the NTPD server role
#
# @param servers The list of NTPD servers. No default value.
#
# @groups network servers
#
class role::ntpd (
  Array[Stdlib::Host] $servers,
) {

  class { '::profile::system::ntpd':
    servers => $servers,
  }
}
