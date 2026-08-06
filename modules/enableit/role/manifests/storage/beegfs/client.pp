# @summary BeeGFS client settings, used when `client` is enabled
#
# @param udp_port The UDP port for the client. Defaults to 8004.
#
# @groups client udp_port
#
class role::storage::beegfs::client (
  Stdlib::Port $udp_port = 8004,
) {
}
