# @summary Class for managing the RustFS Storage role
#
# @param data_dir The host directory where backup data is stored.
# @param version The version of rustfs container image to use.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param env_vars Additional hash of environment variables for the container.
# @param enable Whether to enable and manage the rustfs component.
# @param enable_expose Whether to expose the service via HAProxy.
# @param domains HAProxy domain configuration.
#
# @example Usage
#   include role::storage::rustfs
#
class role::storage::rustfs (
  Stdlib::Unixpath     $data_dir      = '/mnt/backups/rustfs',
  String[1]            $version       = '1.0.0-rc.2',
  String[1]            $access_key    = 'admin',
  String[1]            $secret_key    = 'admin',
  Hash                 $env_vars      = {},
  Boolean              $enable        = true,
  Boolean              $enable_expose = false,
  Eit_haproxy::Domains $domains       = {},
) inherits role::storage {
  contain role::virtualization::docker
  contain profile::storage::rustfs
}
