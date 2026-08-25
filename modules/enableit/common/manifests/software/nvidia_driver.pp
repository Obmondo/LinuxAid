# @summary Class for managing Nvidia Driver installation
#
# @param enable Whether to enable the Nvidia Driver. Defaults to false.
#
# @param manage Whether to manage the Nvidia Driver package. Defaults to false.
#
# @param noop_value Optional boolean for noop mode. Defaults to undef.
#
# @param packages Nvidia driver package names to install. Must be set via hiera (data/os) per OS.
#
# @groups management enable, manage.
#
# @groups configuration noop_value, packages.
#
class common::software::nvidia_driver (
  Boolean               $enable     = false,
  Boolean               $manage     = false,
  Eit_types::Noop_Value $noop_value = undef,
  Array[String[1]]      $packages,
) inherits common {
  if $manage {
    contain profile::software::nvidia_driver
  }
}
