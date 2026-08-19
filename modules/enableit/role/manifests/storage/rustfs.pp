# @summary Class for managing the RustFS Storage role
#
# RustFS is an S3-compatible object storage server, run via docker-compose.
#
# @param endpoint The FQDN of the RustFS endpoint.
#
# @param data_dir The Unix path to the data directory.
#
# @param logs_dir The Unix path to the logs directory.
#
# @param access_key The admin access key.
#
# @param secret_key The admin secret key.
#
# @param image The Docker image to use for RustFS. Defaults to 'rustfs/rustfs:latest'.
#
# @param console_enable Whether to enable the RustFS web console.
#
# @groups directories data_dir, logs_dir.
#
# @groups settings access_key, secret_key, image, console_enable.
#
# @groups network endpoint.
#
class role::storage::rustfs (
  Stdlib::Fqdn     $endpoint,
  Stdlib::Unixpath $data_dir,
  Stdlib::Unixpath $logs_dir,
  String           $access_key,
  String           $secret_key,
  String           $image          = 'rustfs/rustfs:latest',
  Boolean          $console_enable = true,
) inherits role::storage {

  contain role::virtualization::docker
  contain profile::storage::rustfs
}
