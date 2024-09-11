# Freight package signing tool
class profile::package_management::packagesign (
  Boolean              $manage           = $role::package_management::repo::manage,
  Stdlib::Fqdn         $domain           = $role::package_management::repo::domain,
  Stdlib::Absolutepath $basedir          = $role::package_management::repo::basedir,
  String               $signing_password = $role::package_management::repo::signing_password,
  Boolean              $ssl              = $role::package_management::repo::ssl,
  Stdlib::HTTPSUrl     $gitserver_url    = $role::package_management::repo::gitserver_url,
  String               $gitserver_token  = $role::package_management::repo::gitserver_token,
  Optional[String]     $ssl_cert         = $role::package_management::repo::ssl_cert,
  Optional[String]     $ssl_key          = $role::package_management::repo::ssl_key,
  Hash                 $locations        = $role::package_management::repo::locations,
  Array                $volumes          = $role::package_management::repo::volumes,
  String               $registry_path    = $role::package_management::repo::registry_path,
  String               $packagesign_tag  = $role::package_management::repo::packagesign_tag,
  String               $nginx_tag        = $role::package_management::repo::nginx_tag,
  Enum[
    'gitea',
    'gitlab'
  ]                    $provider         = $role::package_management::repo::provider,
) {

  file { default:
    ensure => ensure_dir($manage),
    ;
    '/opt/obmondo/docker-compose/packagesign/.env':
      ensure  => present,
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
        'nginx_tag'       => $nginx_tag,
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
