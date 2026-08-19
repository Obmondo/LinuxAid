# rustfs storage
class profile::storage::rustfs (
  Stdlib::Fqdn     $endpoint       = $role::storage::rustfs::endpoint,
  Stdlib::Unixpath $data_dir       = $role::storage::rustfs::data_dir,
  Stdlib::Unixpath $logs_dir       = $role::storage::rustfs::logs_dir,
  String           $access_key     = $role::storage::rustfs::access_key,
  String           $secret_key     = $role::storage::rustfs::secret_key,
  String           $image          = $role::storage::rustfs::image,
  Boolean          $console_enable = $role::storage::rustfs::console_enable,
) {

  file { default:
    ensure => 'directory',
    ;
    [
      '/opt/obmondo/docker-compose/rustfs',
      $data_dir,
      $logs_dir,
    ]:
    ;
    '/opt/obmondo/docker-compose/rustfs/docker-compose.yaml':
      ensure  => 'present',
      content => epp('profile/docker-compose/rustfs/docker-compose.yaml.epp', {
        endpoint       => $endpoint,
        image          => $image,
        data_dir       => $data_dir,
        logs_dir       => $logs_dir,
        access_key     => $access_key,
        secret_key     => $secret_key,
        console_enable => $console_enable,
      }).node_encrypt::secret,
      require => [
        File['/opt/obmondo/docker-compose/rustfs'],
      ]
      ;
  }

  docker_compose { 'rustfs':
    ensure        => 'present',
    compose_files => [
      '/opt/obmondo/docker-compose/rustfs/docker-compose.yaml',
    ],
    require       => File['/opt/obmondo/docker-compose/rustfs/docker-compose.yaml'],
  }
}
