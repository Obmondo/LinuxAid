# @summary Class for managing the RustFS Storage role
#
# @param data_dir The host directory where backup data is stored.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param enable Whether to enable and manage the rustfs component.
# @param expose Whether to expose the service via HAProxy.
# @param domains HAProxy domain configuration.
#
# @example Usage
#   include role::storage::rustfs
#
class role::storage::rustfs (
  String[1]            $access_key,
  String[1]            $secret_key,
  Stdlib::Unixpath     $data_dir,
  Boolean              $enable        = true,
  Boolean              $expose        = false,
  Eit_haproxy::Domains $domains       = {},
) inherits role::storage {
  contain role::virtualization::docker
  contain profile::storage::rustfs
  if $expose {
    confine($expose, $domains.empty, 'Exposing rustfs via HAProxy requires domains to be provided')

    class { 'role::web::haproxy':
      domains            => $domains,
      version            => '3.2.0',
      encryption_ciphers => 'Intermediate',
    }
  }
}
