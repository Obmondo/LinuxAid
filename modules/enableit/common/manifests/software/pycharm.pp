# @summary Class for managing the PyCharm software
#
# @param manage Boolean parameter to control management of PyCharm. Defaults to true.
#
# @param enable Boolean parameter to enable or disable PyCharm. Defaults to true.
#
# @param version String parameter to control version of PyCharm.
#
# @param noop_value Optional boolean to specify noop mode value.
#
# @groups management manage, enable.
#
# @groups configuration version, noop_value.
#
class common::software::pycharm (
  Boolean               $manage     = false,
  Boolean               $enable     = true,
  Eit_types::Version    $version    = undef,
  Eit_types::Noop_Value $noop_value = undef,
) {

  if $manage {
    contain profile::software::pycharm
  }
}
