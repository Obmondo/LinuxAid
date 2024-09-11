# Nvidia Driver install
class common::software::nvidia_driver (
  Boolean           $enable     = false,
  Boolean           $manage     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::nvidia_driver
  }
}
