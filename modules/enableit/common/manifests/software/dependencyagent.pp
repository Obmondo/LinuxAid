# @summary Class for managing the Microsoft dependency agent common::software::dependencyagent
#
# @param manage Whether to manage the dependency agent. Defaults to false.
#
# @param enable Whether to enable the dependency agent. Defaults to false.
#
# @param noop_value Optional parameter for noop mode value. Defaults to undef.
#
class common::software::dependencyagent (
  Boolean           $manage     = false,
  Boolean           $enable     = false,
  Optional[Boolean] $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::dependencyagent
  }
}
