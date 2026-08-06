# @summary Snapshot settings for the package management repo, used when `snapshot` is enabled
#
# @param retention_days Number of days to retain snapshots before pruning. Set to 0 to disable cleanup. Defaults to 60.
#
# @param image_tag The tag of the repository-snapshot image.
#
# @groups snapshot retention_days, image_tag
#
# `tag` is a Puppet metaparameter — a class param of that name inherits to every contained
# resource, so this stays `image_tag`.
class role::package_management::repo::snapshot (
  Integer[0]       $retention_days = 60,
  Optional[String] $image_tag      = undef,
) {
}
