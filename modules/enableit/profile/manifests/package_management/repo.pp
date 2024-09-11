# repository mirror and snapshot
class profile::package_management::repo (
  Boolean                          $manage  = $role::package_management::repo::manage,
  Eit_types::SystemdTimer::Weekday $weekday = $role::package_management::repo::weekday,
  Eit_types::User                  $user    = $role::package_management::repo::user,
  Stdlib::Unixpath                 $basedir = $role::package_management::repo::basedir,

  Repository::Mirrors::Configurations $configurations = $role::package_management::repo::configurations,
) {

  class { 'repository::mirror':
    enable          => $manage,
    weekday         => $weekday,
    user            => $user,
    basedir         => $basedir,
    configurations  => $configurations,
  }
}
