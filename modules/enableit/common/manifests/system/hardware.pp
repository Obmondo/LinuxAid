# @summary Class for managing hardware features
#
# @param manage_multipath Optional boolean to manage multipath settings. Defaults to false.
#
# @param __multipath_packages Array of strings representing multipath package names. Defaults to an empty array.
#
# @param __multipath_services Array of strings representing multipath service names. Defaults to a predefined list.
#
# @groups multipath manage_multipath, __multipath_packages, __multipath_services
#
class common::system::hardware (
  Optional[Boolean]              $manage_multipath     = false,
  Array[Eit_types::SimpleString] $__multipath_packages = [],
  Array[Eit_types::SimpleString] $__multipath_services = [
    'multipath-tools.service',
    'multipath-tools-boot.service',
    'multipathd.service',
    'multipathd.socket',
  ],
) inherits common::system {
  contain profile::system::hardware
}
