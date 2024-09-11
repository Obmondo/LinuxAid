# Microsoft dependencyagent
class common::software::dependencyagent (
  Boolean           $manage     = false,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::dependencyagent
  }
}
