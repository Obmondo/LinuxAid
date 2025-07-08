# @summary Class for managing the Guix client in system packages
#
# @param enable Whether to enable the Guix client. Defaults to false.
#
# @param manage_mounts Whether to manage mounts for Guix client. Defaults to true.
#
# @param server The server hostname for Guix. Defaults to 'localhost'.
#
class common::system::package_management::guix::client (
  Boolean $enable       = false,
  Boolean $manage_mounts = true,
  Stdlib::Host $server   = 'localhost',
) {
  contain ::profile::package_management::guix::client
}
