# Cloud Init
class common::system::cloud_init (
  Boolean $manage = false,
) inherits ::common::system {

  if $manage {
    confine_systemd()
    include profile::system::cloud_init
  }
}
