# Stunnel setup
class common::network::stunnel (
  Hash $tunnels = {},
) inherits common::network {

  $tunnels.each |$_name, $_tun| {
    stunnel::tun { $_name:
      * => $_tun,
    }
  }
}
