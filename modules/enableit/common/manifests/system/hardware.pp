# Hardware features
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
