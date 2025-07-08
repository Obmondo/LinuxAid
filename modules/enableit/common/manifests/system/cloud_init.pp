# @summary Class for managing system cloud init configuration
#
# @param manage Whether to manage cloud init. Defaults to false.
#
class common::system::cloud_init (
  Boolean $manage = false,
) inherits ::common::system {
  if $manage {
    confine_systemd()
    include profile::system::cloud_init
  }
}
