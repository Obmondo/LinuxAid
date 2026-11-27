# @summary Class for managing the RustFS Storage role
#
# @param data_dir The host directory where backup data is stored.
# @param access_key The S3 access key ID.
# @param secret_key The S3 secret access key.
# @param enable Whether to enable and manage the rustfs component.
# @param expose Whether to expose the service via HAProxy.
# @param version The rustfs/rustfs image tag to run, e.g. '1.0.7'. Bumping it
#   is all an upgrade needs; puppet recreates the container on the new image.
#   https://github.com/rustfs/rustfs/releases
# @param listen_address Address the container publishes its ports on. Keep it
#   at 127.0.0.1 where HAProxy on the same host fronts the service, so the S3
#   API and console are not reachable without going through the proxy.
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
  String[1]            $listen_address = '0.0.0.0',
  Eit_types::Rustfs::Version $version  = '1.0.7',
) inherits role::storage {
  contain role::virtualization::docker
  contain profile::storage::rustfs
  if $expose {
    include role::web::haproxy
  }
}
