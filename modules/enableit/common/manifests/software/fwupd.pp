# Fwupd-refresh
class common::software::fwupd (
  Boolean           $manage     = false,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::fwupd
  }
}
