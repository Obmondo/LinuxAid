# @summary Class for managing the RustFS Storage role
#
# @param data_dir The host directory where backup data is stored.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param enable Whether to enable and manage the rustfs component.
# @param expose Whether to expose the service via HAProxy.
# @param listen_address Address the container publishes its ports on; loopback by
#   default so only a proxy on the same host can reach it.
#
# @example Usage
#   include role::storage::rustfs
#
class role::storage::rustfs (
  String[1]            $access_key,
  String[1]            $secret_key,
  Stdlib::Unixpath     $data_dir,
  Boolean              $enable         = true,
  Boolean              $expose         = false,
  String[1]            $listen_address = '127.0.0.1',
) inherits role::storage {
  contain role::virtualization::docker
  contain profile::storage::rustfs
  if $expose {
    include role::web::haproxy
  }
}
