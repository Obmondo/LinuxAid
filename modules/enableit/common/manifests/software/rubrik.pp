# @summary Class for managing the Rubrik Agent software
#
# @param manage Boolean parameter to control management of the Rubrik Agent. Defaults to false.
#
# @param enable Boolean parameter to enable or disable the Rubrik Agent. Defaults to false.
#
# @param noop_value Optional boolean to specify noop mode value.
#
# @groups agent_management manage, enable.
#
# @groups settings noop_value.
#
class common::software::rubrik (
  Boolean               $manage     = false,
  Boolean               $enable     = false,
  Eit_types::Noop_Value $noop_value = undef,
) inherits common {
  if $manage {
    contain profile::software::rubrik
  }
}
