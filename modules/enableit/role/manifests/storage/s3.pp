
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
# @param roles
#   All S3 accounts, keyed by name. `owns` is optional (omit it entirely for
#   an account that owns no buckets - e.g. a plain grantee identity). Under
#   `owns`, each key is a bucket the account owns: its credentials apply that
#   bucket's policy (the S3 PutBucketPolicy call has to be authenticated as
#   an account with rights over the bucket - the owner). Ownership is
#   therefore structural, not a separate field. Each bucket's `grants` maps a
#   grantee account name to the grant level applied for it:
#   - `read`: `s3:GetObject` + `s3:ListBucket`.
#   - `write`: `s3:PutObject` + `s3:ListBucket` + `s3:GetBucketVersioning`
#     - no `s3:GetObject`, the account genuinely can't read existing
#     content.
#   - `readwrite`: everything `write` grants, plus `s3:GetObject` - needed
#     by replication clients (e.g. RustFS) that HEAD/GET the destination
#     object before uploading, which `write` alone can't satisfy.
#   - `admin`: full access (`s3:*`) on the bucket - the broadest grant.
#
#   Each grantee name must match an account declared here, otherwise that
#   grant is skipped with a warning.
#
# @example Hiera
#   role::storage::s3::roles:
#     app:
#       access_key: ENC[PKCS7,...]
#       email: app@example.com
#       owns:
#         app-logs-backup:
#           grants:
#             backup-exporter: read
#         app-uploads:
#           grants:
#             upload-only: write
#             replication-backup: readwrite
#     backup-exporter:
#       access_key: ENC[PKCS7,...]
#       email: backup-exporter@example.com
#     upload-only:
#       access_key: ENC[PKCS7,...]
#       email: upload-only@example.com
#     replication-backup:
#       access_key: ENC[PKCS7,...]
#       email: replication-backup@example.com
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
  Stdlib::Fqdn               $endpoint,
  Stdlib::Unixpath           $data_dir,
  Stdlib::Unixpath           $metadata_dir,
  Stdlib::Unixpath           $conf_dir,
  Eit_types::Storage::S3::Role $roles,
  Boolean                    $manage = true,
  String                     $image  = 'zenko/cloudserver:latest-7.10.19',
) inherits role::storage {

  contain role::virtualization::docker
  contain profile::storage::s3
}
