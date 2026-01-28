# @summary Class for managing Guix client setup
#
# @param manage Whether to manage Guix setup. Defaults to true.
class common::system::guix (
  Boolean $manage        = false,
  Boolean $enable        = false,
  Boolean $manage_mounts = true,
  Stdlib::Host $server   = 'localhost',
) inherits ::common::system {

  if $manage {
    contain ::profile::system::guix
  }
}
