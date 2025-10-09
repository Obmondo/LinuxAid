# @summary custom data type for an array with wireguard peers
#
# @author Tim Meusel <tim@bastelfreak.de>
# @author Sebastian Rakel <sebastian@devunit.eu>
#
# @see https://www.freedesktop.org/software/systemd/man/systemd.netdev.html#%5BWireGuardPeer%5D%20Section%20Options
type Wireguard::Peers = Array[
  Struct[{
    public_key           => String[1],
    preshared_key        => Optional[String[1]],
    allowed_ips          => Optional[Array[String[1]]],
    endpoint             => Optional[String[1]],
    persistent_keepalive => Optional[Stdlib::Port],
    description          => Optional[String[1]],
  }]
]
