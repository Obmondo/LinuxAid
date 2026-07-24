# s3 storage
class profile::storage::s3 (
  Stdlib::Fqdn     $endpoint     = $role::storage::s3::endpoint,
  Boolean          $manage       = $role::storage::s3::manage,
  Stdlib::Unixpath $data_dir     = $role::storage::s3::data_dir,
  Stdlib::Unixpath $metadata_dir = $role::storage::s3::metadata_dir,
  String           $image        = $role::storage::s3::image,
  Stdlib::Unixpath $conf_dir     = $role::storage::s3::conf_dir,

  Eit_types::Storage::S3::Role $roles = $role::storage::s3::roles,
) {

  # TODO: function does not work as it should
  #s3_roles($roles)

  # TODO: Add a check for shortid should not be a duplicate
  $_accounts = $roles.reduce([]) |$acc, $role| {
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

  $_admin_creds = $roles.map |$_name, $_opts| {
    { 'accessKey' => $_name, 'secretKey' => $_opts['access_key'] }
  }

  # Build one policy per owned bucket. Ownership is structural: the account
  # a bucket sits under (`owns`) is the one whose credentials apply the
  # policy (PutBucketPolicy must authenticate as an account with rights over
  # the bucket). Each grant names a grantee account and its role level so
  # s3-policy-init.sh can build the right statements.
  $_bucket_policies = $roles.reduce([]) |$acc, $role| {
    [$_owner, $owner_opts] = $role

    $_owned = pick_default($owner_opts['owns'], {}).reduce([]) |$bucket_acc, $bucket_entry| {
      [$_bucket, $_spec] = $bucket_entry

      $_grants = $_spec['grants'].reduce([]) |$grant_acc, $grant| {
        [$_grantee, $_access] = $grant
        if $_grantee in $roles {
          $_g_opts = $roles[$_grantee]
          $_g_seed = "${_g_opts['email']}_${_grantee}"
          $grant_acc << {
            'accessKey'   => $_grantee,
            'secretKey'   => $_g_opts['access_key'],
            'canonicalId' => seeded_rand_string(65, $_g_seed),
            'shortid'     => String(123456789013 + seeded_rand(999, $_g_seed)),
            'access'      => $_access,
          }
        } else {
          warning("S3 bucket policy: grantee '${_grantee}' for bucket '${_bucket}' (owned by '${_owner}') not found among roles, skipping")
          $grant_acc
        }
      }

      if empty($_grants) {
        $bucket_acc
      } else {
        $bucket_acc << {
          'bucket'         => $_bucket,
          'ownerAccessKey' => $_owner,
          'ownerSecretKey' => $owner_opts['access_key'],
          'grants'         => $_grants,
        }
      }
    }

    $acc + $_owned
  }

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
        adminAccounts  => $_admin_creds,
        bucketPolicies => $_bucket_policies,
      }).node_encrypt::secret,
    ;
    '/opt/obmondo/docker-compose/s3/s3-policy-init.sh':
      ensure  => file,
      mode    => '0755',
      content => epp('profile/docker-compose/s3/s3-policy-init.sh.epp', {
        endpoint => $endpoint,
      }),
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
