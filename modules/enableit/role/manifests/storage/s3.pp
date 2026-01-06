
# @summary Class for managing the S3 Storage role
#
# @param endpoint The FQDN of the S3 endpoint.
#
# @param data_dir The Unix path to the data directory.
#
# @param metadata_dir The Unix path to the metadata directory.
#
# @param conf_dir The Unix path to the configuration directory.
#
# @param roles The S3 storage roles.
#
# @param manage Whether to manage the S3 storage resources. Defaults to true.
#
# @param image The Docker image to use for S3. Defaults to 'zenko/cloudserver:latest-7.10.19'.
#
# @groups directories data_dir, metadata_dir, conf_dir.
#
# @groups settings roles, manage, image.
#
# @groups network endpoint.
#
class role::storage::s3 (
  Stdlib::Fqdn     $endpoint,
  Stdlib::Unixpath $data_dir,
  Stdlib::Unixpath $metadata_dir,
  Stdlib::Unixpath $conf_dir,
  Eit_types::Storage::S3 $roles,
  Boolean      $manage = true,
  String       $image  = 'zenko/cloudserver:latest-7.10.19',
) inherits role::storage {

  contain role::virtualization::docker
  contain profile::storage::s3
}
