# Class clientbucket contains settings for puppet cache cleanup
class common::puppet::clientbucket (
  Boolean       $enable       = true,
  Integer[0,23] $cleanup_hour = 0,
) {
  contain ::profile::puppet::clientbucket
}
