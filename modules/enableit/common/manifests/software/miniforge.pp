# @summary Class for managing the Miniforge software
#
# @param manage Boolean parameter to control management of Miniforge. Defaults to false.
#
# @param enable Boolean parameter to enable or disable Miniforge. Defaults to true.
#
# @param version String parameter to control version of Miniforge3.
#
# @param noop_value Optional boolean to specify noop mode value.
#
class common::software::miniforge (
  Boolean               $manage     = true,
  Boolean               $enable     = true,
  Eit_types::Version    $version    = '25.3.1-0',
  Eit_types::Noop_Value $noop_value = undef,
) {

  if $manage {
    contain profile::software::miniforge
  }
}
