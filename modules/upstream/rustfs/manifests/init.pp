# @summary Main class for managing rustfs
#
# This class provides high-level control over whether rustfs
# should be managed via Docker Compose.
#
# @param enable
#   Whether to enable and manage the rustfs component.
# @param data_dir
#   The host directory where backup data is stored.
# @param version
#   The version of rustfs container image to use.
# @param access_key
#   The S3 access key ID for authentication.
# @param secret_key
#   The S3 secret access key for authentication.
# @param env_vars
#   Additional hash of environment variables for the container.
#
# @example Basic usage
#   include rustfs
#
class rustfs (
  Boolean          $enable     = false,
  Stdlib::Unixpath $data_dir   = '/opt/rustfs/data',
  String[1]        $version    = lookup('rustfs::version'),
  String[1]        $access_key = lookup('rustfs::access_key'),
  String[1]        $secret_key = lookup('rustfs::secret_key'),
  Hash             $env_vars   = {},
) {
  include docker

  $_osname = $facts['os']['name']
  if $_osname != 'Ubuntu' {
    fail("The OS you running (${_osname}) isn't supported to setup rustfs")
  }

  $container_image = lookup('rustfs::container_image')
  $compose_dir     = '/opt/obmondo/docker-compose/rustfs'

  $_merged_env = {
    'RUSTFS_ACCESS_KEY' => $access_key,
    'RUSTFS_SECRET_KEY' => $secret_key,
  } + $env_vars

  if $enable {
    # Validate data_dir existence
    if !inline_template('<%= File.directory?(@data_dir) %>') == 'true' {
      fail("rustfs: data_dir ${data_dir} must be pre-mounted and managed by system-level configuration.")
    }

    file { $compose_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { "${compose_dir}/docker-compose.yml":
      ensure  => file,
      content => epp('rustfs/docker-compose.yml.epp', {
          'image'    => $container_image,
          'version'  => $version,
          'data_dir' => $data_dir,
          'env_vars' => $_merged_env,
      }),
      require => File[$compose_dir],
    }

    docker_compose { 'rustfs':
      ensure        => present,
      compose_files => ["${compose_dir}/docker-compose.yml"],
      subscribe     => File["${compose_dir}/docker-compose.yml"],
    }
  } else {
    docker_compose { 'rustfs':
      ensure        => absent,
      compose_files => ["${compose_dir}/docker-compose.yml"],
    }
  }
}
