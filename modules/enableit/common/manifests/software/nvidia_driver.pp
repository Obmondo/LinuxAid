# @summary Class for managing Nvidia Driver installation
#
# @param enable Whether to enable the Nvidia Driver. Defaults to false.
#
# @param manage Whether to manage the Nvidia Driver package. Defaults to false.
#
# @param noop_value Optional boolean for noop mode. Defaults to undef.
#
class common::software::nvidia_driver (
  Boolean           $enable     = false,
  Boolean           $manage     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {
  if $manage {
    contain profile::software::nvidia_driver
  }
}
