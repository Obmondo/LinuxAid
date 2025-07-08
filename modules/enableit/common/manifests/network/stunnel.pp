# @summary Class for setting up Stunnel configurations
#
# @param tunnels A hash of tunnel configurations. Defaults to an empty hash.
#
class common::network::stunnel (
  Hash $tunnels = {},
) inherits common::network {

  $tunnels.each |$_name, $_tun| {
    stunnel::tun { $_name:
      * => $_tun,
    }
  }
}
