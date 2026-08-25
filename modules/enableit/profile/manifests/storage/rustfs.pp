# @summary RustFS storage profile
#
# @param data_dir The host directory where backup data is stored.
# @param version The version of rustfs container image to use.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param env_vars Additional hash of environment variables for the container.
# @param enable Whether to enable and manage the rustfs component.
#
class profile::storage::rustfs (
  String[1]            $access_key    = $role::storage::rustfs::access_key,
  String[1]            $secret_key    = $role::storage::rustfs::secret_key,
  Boolean              $enable        = $role::storage::rustfs::enable,
  Stdlib::Unixpath     $data_dir      = $role::storage::rustfs::data_dir,
  String[1]            $version       = '1.0.0-rc.3',
  Hash                 $env_vars      = {},
) {
  # 1. Manage RustFS
  class { 'rustfs':
    access_key => $access_key,
    secret_key => $secret_key,
    enable     => $enable,
    data_dir   => $data_dir,
    version    => $version,
    env_vars   => $env_vars,
  }
}
