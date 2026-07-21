
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
#   All S3 accounts, keyed by name. `bucket_access` is optional (omit it
#   entirely for an account with nothing to declare - e.g. a plain identity
#   that only ever acts as another entry's `managed_by`). For every
#   `bucket_access` entry, `managed_by` names the account whose credentials
#   get used to actually apply that bucket's policy (the S3 PutBucketPolicy
#   call has to be authenticated as an account with rights over that
#   bucket - typically its real owner), and `role` is the grant level
#   applied for the entry's own account:
#   - `read`: `s3:GetObject` + `s3:ListBucket`.
#   - `write`: `s3:PutObject` + `s3:ListBucket` + `s3:GetBucketVersioning`
#     - no `s3:GetObject`, the account genuinely can't read existing
#     content.
#   - `readwrite`: everything `write` grants, plus `s3:GetObject` - needed
#     by replication clients (e.g. RustFS) that HEAD/GET the destination
#     object before uploading, which `write` alone can't satisfy.
#   - `admin`: full access (`s3:*`) on the bucket - the broadest grant,
#     not a claim of ownership; `managed_by` still names whose
#     credentials apply the policy.
#
#   `managed_by` must match the name of an account declared here,
#   otherwise that bucket_access entry is skipped with a warning.
#
# @example Hiera
#   role::storage::s3::roles:
#     app:
#       access_key: ENC[PKCS7,...]
#       email: app@example.com
#     backup-exporter:
#       access_key: ENC[PKCS7,...]
#       email: backup-exporter@example.com
#       bucket_access:
#         - bucket: app-logs-backup
#           role: read
#           managed_by: app
#     upload-only:
#       access_key: ENC[PKCS7,...]
#       email: upload-only@example.com
#       bucket_access:
#         - bucket: app-uploads
#           role: write
#           managed_by: app
#     replication-backup:
#       access_key: ENC[PKCS7,...]
#       email: replication-backup@example.com
#       bucket_access:
#         - bucket: app-uploads
#           role: readwrite
#           managed_by: app
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
