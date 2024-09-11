# Guix client
class common::system::package_management::guix (
  Boolean $manage = true,
) inherits ::common::system {

  if $manage {
    contain ::common::system::package_management::guix::client
  }
}
