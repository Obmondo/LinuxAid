# @summary BeeGFS metadata service settings, used when `meta` is enabled
#
# @param port The port for the metadata service. Defaults to 8005.
#
# @groups meta port
#
class role::storage::beegfs::meta (
  Stdlib::Port $port = 8005,
) {
}
