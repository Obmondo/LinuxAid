# @summary Class for pushing local directories to offsite S3 buckets with restic
#
# Each entry in repos becomes a common::backup::s3::repo, see that define for
# the accepted keys.
#
# @param repos Hash of restic repositories to push, keyed by repository name.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups backup repos
#
# @groups other encrypt_params
#
# @encrypt_params repos.*.password, repos.*.secret_access_key
#
class common::backup::s3 (
  Hash[String, Hash]         $repos          = {},
  Eit_types::Encrypt::Params $encrypt_params = [
    'repos.*.password',
    'repos.*.secret_access_key',
  ],
) inherits common::backup {

  $repos.each |$k, $v| {
    common::backup::s3::repo { $k:
      * => $v,
    }
  }
}
