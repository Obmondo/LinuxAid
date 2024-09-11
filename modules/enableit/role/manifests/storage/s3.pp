# S3 Storage
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
