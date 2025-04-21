# s3 storage
class profile::storage::s3 (
  Stdlib::Fqdn     $endpoint     = $role::storage::s3::endpoint,
  Boolean          $manage       = $role::storage::s3::manage,
  Stdlib::Unixpath $data_dir     = $role::storage::s3::data_dir,
  Stdlib::Unixpath $metadata_dir = $role::storage::s3::metadata_dir,
  String           $image        = $role::storage::s3::image,
  Stdlib::Unixpath $conf_dir     = $role::storage::s3::conf_dir,

  Eit_types::Storage::S3 $roles = $role::storage::s3::roles,
) {

  # TODO: function does not work as it should
  #s3_roles($roles)

  # TODO: Add a check for shortid should not be a duplicate
  $_roles = $roles.reduce([]) |$acc, $role| {
    [$_name, $opts] = $role

    $_shortid = 123456789013 + seeded_rand(999, "${opts['email']}_${_name}")
    $_arn = "arn:aws:iam::${_shortid}:root"

    $acc << {
      name        => $_name,
      canonicalID => seeded_rand_string(65, "${opts['email']}_${_name}"),
      email       => $opts['email'],
      arn         => $_arn,
      shortid     => String($_shortid),
      keys        => [{
        'access' => $_name,
        'secret' => $opts[unwarp(access_key)],
      }]
    }
  }

  file { default:
    ensure  => ensure_dir($manage),
    ;
    [
      '/opt/obmondo/docker-compose/s3',
      $data_dir,
      $metadata_dir,
      $conf_dir,
    ]:
    ;
    "${conf_dir}/authdata.json":
      ensure  => ensure_present($manage),
      content => to_json_pretty({
        accounts => $_roles,
      }),
    ;
    '/opt/obmondo/docker-compose/s3/docker-compose.yaml':
      ensure  => ensure_present($manage),
      content => epp('profile/docker-compose/s3/docker-compose.yaml.epp', {
        endpoint     => $endpoint,
        image        => $image,
        data_dir     => $data_dir,
        metadata_dir => $metadata_dir,
        conf_dir     => $conf_dir,
      }),
      require => [
        File['/opt/obmondo/docker-compose/s3'],
      ]
      ;
  }

  docker_compose { 's3':
    ensure        => ensure_present($manage),
    compose_files => [
      '/opt/obmondo/docker-compose/s3/docker-compose.yaml',
    ],
    require       => File['/opt/obmondo/docker-compose/s3/docker-compose.yaml'],
  }
}
