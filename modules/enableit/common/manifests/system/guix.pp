# @summary Class for managing Guix client setup
#
# @param manage Whether to manage Guix setup. Defaults to true.
#
# @param enable Whether to enable Guix. Defaults to false.
#
# @param manage_mounts Whether to manage Guix mounts. Defaults to true.
#
# @param server The Guix server hostname. Defaults to 'localhost'.
#
# @groups settings manage, enable
#
# @groups configuration manage_mounts, server
#
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
