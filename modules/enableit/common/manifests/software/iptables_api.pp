# @summary Class for installing iptables-api
#
# @param enable 
# Enable the iptables-api installation. Defaults to false.
#
# @param manage Whether to manage the iptables-api resource. Defaults to false.
#
# @param noop_value Optional boolean to specify noop mode. Defaults to undef.
#
# @param listen_address The IP address and port to listen on. Defaults to '0.0.0.0:58080'.
#
class common::software::iptables_api (
  Boolean           $enable         = false,
  Boolean           $manage         = false,
  Optional[Boolean] $noop_value     = undef,
  Eit_types::IPPort $listen_address = '0.0.0.0:58080',
) inherits common {
  if $manage {
    contain profile::software::iptables_api
  }
}
