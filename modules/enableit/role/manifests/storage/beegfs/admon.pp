# @summary BeeGFS administration service settings, used when `admon` is enabled
#
# @param http_port The HTTP port for the administration service. Defaults to 8000.
#
# @groups admon http_port
#
class role::storage::beegfs::admon (
  Stdlib::Port $http_port = 8000,
) {
}
