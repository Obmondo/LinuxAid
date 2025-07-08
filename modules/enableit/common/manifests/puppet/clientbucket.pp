# @summary Class clientbucket contains settings for puppet cache cleanup
#
# @param enable Enable or disable puppet cache cleanup. Defaults to true.
#
# @param cleanup_hour The hour of the day (0-23) when cleanup should run. Defaults to 0.
#
class common::puppet::clientbucket (
  Boolean       $enable       = true,
  Integer[0,23] $cleanup_hour = 0,
) {
  contain ::profile::puppet::clientbucket
}
