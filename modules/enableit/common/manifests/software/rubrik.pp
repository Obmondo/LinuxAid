# Rubrik Agent
class common::software::rubrik (
  Boolean           $manage     = false,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::rubrik
  }
}
