# Hardware features
class profile::system::hardware (
  Optional[Boolean]              $manage_multipath     = $common::system::hardware::manage_multipath,
  Array[Eit_types::SimpleString] $__multipath_packages = $common::system::hardware::__multipath_packages,
  Array[Eit_types::SimpleString] $__multipath_services = $common::system::hardware::__multipath_services,
) {

  if $manage_multipath {
    fail('enabling multipath not yet supported')
  }

  if $__multipath_services.size {
    service { $__multipath_services:
      ensure => ensure_service($manage_multipath),
      before => Package[$__multipath_packages],
    }
  }

  if $__multipath_packages.size > 0 {
    package { $__multipath_packages:
      ensure => ensure_present($manage_multipath),
    }
  }
}
