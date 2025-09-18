# @summary Class for managing the Rustdesk software
#
# @param manage Boolean parameter to control management of the Rustdesk. Defaults to false.
#
# @param enable Boolean parameter to enable or disable the Rustdesk. Defaults to false.
#
# @param version String parameter to control version of the Rustdesk.
#
# @param noop_value Optional boolean to specify noop mode value.
#
class common::software::rustdesk (
  Boolean            $manage       = true,
  Boolean            $enable       = true,
  Eit_types::Version $version      = undef,
  Optional[Boolean]  $noop_value   = undef,
  Array[String]      $dependencies = [],
) {

  if $manage {
    contain profile::software::rustdesk
  }
}
