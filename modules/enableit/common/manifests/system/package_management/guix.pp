# @summary Class for managing Guix client setup
#
# @param manage Whether to manage Guix setup. Defaults to true.
#
class common::system::package_management::guix (
  Boolean $manage = true,
) inherits ::common::system {
  if $manage {
    contain ::common::system::package_management::guix::client
  }
}
