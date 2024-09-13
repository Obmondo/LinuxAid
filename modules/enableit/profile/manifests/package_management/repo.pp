# repository mirror and snapshot
class profile::package_management::repo (
  Boolean                             $manage           = $role::package_management::repo::manage,
  Eit_types::SystemdTimer::Weekday    $weekday          = $role::package_management::repo::weekday,
  Eit_types::User                     $user             = $role::package_management::repo::user,
  Stdlib::Unixpath                    $basedir          = $role::package_management::repo::basedir,
  String                              $registry_path    = $role::package_management::repo::registry_path,
  String                              $nginx_tag        = $role::package_management::repo::nginx_tag,
  Repository::Mirrors::Configurations $configurations   = $role::package_management::repo::configurations,
) {

  class { 'repository::mirror':
    enable          => $manage,
    weekday         => $weekday,
    user            => $user,
    basedir         => $basedir,
    configurations  => $configurations,
  }

  file { '/opt/obmondo/docker-compose/repository' :
    ensure => ensure_dir($manage),
    ;
    '/opt/obmondo/docker-compose/repository/docker-compose.yaml':
      ensure  => ensure_present($manage),
      content => epp('profile/docker-compose/repository/docker-compose.yaml.epp', {
        'basedir'         => $basedir,
        'registry_path'   => $registry_path,
        'nginx_tag'       => $nginx_tag,
      }),
    ;
  }
}
