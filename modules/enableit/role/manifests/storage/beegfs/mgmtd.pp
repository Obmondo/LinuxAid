# @summary BeeGFS management daemon settings, used when `mgmtd` is enabled
#
# @param port The port for the management daemon. Defaults to 8008.
#
# @groups mgmtd port
#
class role::storage::beegfs::mgmtd (
  Stdlib::Port $port = 8008,
) {
}
