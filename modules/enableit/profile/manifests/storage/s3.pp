# s3 storage
class profile::storage::s3 (
  Stdlib::Fqdn     $endpoint     = $role::storage::s3::endpoint,
  Boolean          $manage       = $role::storage::s3::manage,
  Stdlib::Unixpath $data_dir     = $role::storage::s3::data_dir,
  Stdlib::Unixpath $metadata_dir = $role::storage::s3::metadata_dir,
  String           $image        = $role::storage::s3::image,
  Stdlib::Unixpath $conf_dir     = $role::storage::s3::conf_dir,

  Eit_types::Storage::S3 $roles = $role::storage::s3::roles,

  Eit_types::Storage::S3::ReadOnly $read_only_roles = $role::storage::s3::read_only_roles,
) {

  # TODO: function does not work as it should
  #s3_roles($roles)

  # TODO: Add a check for shortid should not be a duplicate
  $_admin_accounts = $roles.reduce([]) |$acc, $role| {
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
        'secret' => $opts['access_key'],
      }]
    }
  }

  $_readonly_accounts = $read_only_roles.reduce([]) |$acc, $role| {
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
        'secret' => $opts['access_key'],
      }]
    }
  }

  $_accounts = $_admin_accounts + $_readonly_accounts

  $_admin_creds = $roles.map |$_name, $_opts| {
    { 'accessKey' => $_name, 'secretKey' => $_opts['access_key'] }
  }

  $_readonly_creds = $read_only_roles.map |$_name, $_opts| {
    { 'accessKey' => $_name, 'secretKey' => $_opts['access_key'] }
  }

  $_readonly_canonical_ids = $read_only_roles.map |$_name, $_opts| {
    seeded_rand_string(65, "${_opts['email']}_${_name}")
  }

  # Build per-bucket read-only policies grouped by (bucket, owner)
  $_raw_policies = $read_only_roles.reduce([]) |$acc, $role| {
    [$_ro_name, $_ro_opts] = $role
    $_ro_canonical_id = seeded_rand_string(65, "${_ro_opts['email']}_${_ro_name}")
    $_ro_shortid = 123456789013 + seeded_rand(999, "${_ro_opts['email']}_${_ro_name}")

    $_entries = $_ro_opts['buckets'].reduce([]) |$inner_acc, $be| {
      if $be['owner'] in $roles {
        $inner_acc << {
          'bucket'           => $be['bucket'],
          'ownerAccessKey'   => $be['owner'],
          'ownerSecretKey'   => $roles[$be['owner']]['access_key'],
          'readOnlyAccounts' => [{
            'accessKey'   => $_ro_name,
            'secretKey'   => $_ro_opts['access_key'],
            'canonicalId' => $_ro_canonical_id,
            'shortid'     => String($_ro_shortid),
          }],
        }
      } else {
        warning("S3 bucket policy: owner '${be['owner']}' not found in roles, skipping bucket '${be['bucket']}' for read-only role '${$_ro_name}'")
        $inner_acc
      }
    }

    $acc + $_entries
  }

  $_bucket_policies = $_raw_policies.reduce({}) |$map, $entry| {
    $_key = "${entry['bucket']}|${entry['ownerAccessKey']}"
    if $_key in $map {
      $_existing = $map[$_key]
      $map + { $_key => {
        'bucket'           => $_existing['bucket'],
        'ownerAccessKey'   => $_existing['ownerAccessKey'],
        'ownerSecretKey'   => $_existing['ownerSecretKey'],
        'readOnlyAccounts' => $_existing['readOnlyAccounts'] + $entry['readOnlyAccounts'],
      }}
    } else {
      $map + { $_key => $entry }
    }
  }.values

  file { default:
    ensure => ensure_dir($manage),
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
      content => stdlib::to_json_pretty({
        accounts => $_accounts,
      }).node_encrypt::secret,
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
    "${conf_dir}/s3-sideloader-config.json":
      ensure  => file,
      content => stdlib::to_json_pretty({
        adminAccounts        => $_admin_creds,
        readOnlyAccounts     => $_readonly_creds,
        readOnlyCanonicalIds => $_readonly_canonical_ids,
        bucketPolicies       => $_bucket_policies,
      }).node_encrypt::secret,
    ;
    '/opt/obmondo/docker-compose/s3/s3-policy-init.sh':
      ensure  => file,
      mode    => '0755',
      content => epp('profile/docker-compose/s3/s3-policy-init.sh.epp'),
      require => File['/opt/obmondo/docker-compose/s3'],
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
