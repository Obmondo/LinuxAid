# @summary BeeGFS storage service settings, used when `storage` is enabled
#
# @param directory The directory for BeeGFS storage. Defaults to '/local/beegfs'.
#
# @param port The port for the storage service. Defaults to 8003.
#
# @groups storage directory, port
#
class role::storage::beegfs::storage (
  Array[Stdlib::Absolutepath] $directory = '/local/beegfs',
  Stdlib::Port                $port      = 8003,
) {
}
