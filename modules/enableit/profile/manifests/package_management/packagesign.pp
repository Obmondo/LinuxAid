# Freight package signing tool
class profile::package_management::packagesign (
  Boolean              $manage           = $role::package_management::repo::manage,
  Boolean              $packagesign      = $role::package_management::repo::packagesign,
  Stdlib::Fqdn         $domain           = $role::package_management::repo::domain,
  Stdlib::Absolutepath $basedir          = $role::package_management::repo::basedir,
  Hash                 $locations        = $role::package_management::repo::locations,
  Array                $volumes          = $role::package_management::repo::volumes,
  String               $registry_path    = $role::package_management::repo::registry_path,
  String               $packagesign_tag  = $role::package_management::repo::packagesign_tag,

  Optional[Enum['gitlab']]   $provider         = $role::package_management::repo::provider,
  Optional[String]           $signing_password = $role::package_management::repo::signing_password,
  Optional[Stdlib::HTTPSUrl] $gitserver_url    = $role::package_management::repo::gitserver_url,
  Optional[String]           $gitserver_token  = $role::package_management::repo::gitserver_token,
) {

  file {
    '/opt/obmondo/docker-compose/packagesign':
      ensure => ensure_dir($manage),
    ;
    '/opt/obmondo/docker-compose/packagesign/.env':
      ensure  => ensure_present($packagesign),
      content => anything_to_ini({
        'TOKEN' => $gitserver_token,
        'PASS'  => $signing_password,
      }),
    ;
    '/opt/obmondo/docker-compose/packagesign/docker-compose.yaml':
      ensure  => ensure_present($manage),
      content => epp('profile/docker-compose/packagesign/docker-compose.yaml.epp', {
        'basedir'         => $basedir,
        'baseurl'         => $gitserver_url,
        'volumes'         => $volumes,
        'provider'        => $provider,
        'registry_path'   => $registry_path,
        'packagesign_tag' => $packagesign_tag,
        'packagesign'     => $packagesign,
      }),
    ;
  }

  docker_compose { 'packagesign':
    ensure        => ensure_present($manage),
    compose_files => [
      '/opt/obmondo/docker-compose/packagesign/docker-compose.yaml',
    ],
    require       => File['/opt/obmondo/docker-compose/packagesign/docker-compose.yaml'],
  }
}
