# Freight package signing tool
class profile::package_management::packagesign (
  Boolean                     $manage           = $role::package_management::repo::manage,
  Boolean                     $packagesign      = $role::package_management::repo::packagesign,
  Boolean                     $snapshot         = $role::package_management::repo::snapshot,
  Stdlib::Absolutepath        $basedir          = $role::package_management::repo::basedir,
  Hash                        $locations        = $role::package_management::repo::locations,
  Array                       $volumes          = $role::package_management::repo::volumes,
  String                      $registry_path    = $role::package_management::repo::registry_path,
  Optional[String]            $server_tag       = $role::package_management::repo::server_tag,
  Optional[String]            $script_tag       = $role::package_management::repo::script_tag,
  String                      $nginx_path       = $role::package_management::repo::nginx_path,
  String                      $nginx_tag        = $role::package_management::repo::nginx_tag,
  Optional[String]            $snapshot_tag     = $role::package_management::repo::snapshot_tag,
  Optional[Enum['gitlab']]    $provider         = $role::package_management::repo::provider,
  Optional[String]            $signing_password = $role::package_management::repo::signing_password,
  Optional[Stdlib::HTTPSUrl]  $gitserver_url    = $role::package_management::repo::gitserver_url,
  Optional[String]            $gitserver_token  = $role::package_management::repo::gitserver_token,
) {

  file {
    '/opt/obmondo/docker-compose/packagesign':
      ensure => ensure_dir($manage),
    ;
    '/opt/obmondo/docker-compose/packagesign/.env':
      ensure  => ensure_present($packagesign),
      content => anything_to_ini({
        'TOKEN' => $provider ? {
          undef   => '',
          default => node_encrypt::secret($gitserver_token),
        },
        'PASS'  => $packagesign ? {
          true    => node_encrypt::secret($signing_password),
          default => '',
        },
      }),
    ;
    '/opt/obmondo/docker-compose/packagesign/docker-compose.yaml':
      ensure  => ensure_present($manage),
      content => epp('profile/docker-compose/packagesign/docker-compose.yaml.epp', {
        'basedir'       => $basedir,
        'baseurl'       => $gitserver_url,
        'volumes'       => $volumes,
        'provider'      => $provider,
        'registry_path' => $registry_path,
        'server_tag'    => $server_tag,
        'script_tag'    => $script_tag,
        'packagesign'   => $packagesign,
        'snapshot'      => $snapshot,
        'snapshot_tag'  => $snapshot_tag,
        'nginx_path'    => $nginx_path,
        'nginx_tag'     => $nginx_tag,
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
