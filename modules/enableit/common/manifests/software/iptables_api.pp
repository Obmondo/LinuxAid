# iptables-api install
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

