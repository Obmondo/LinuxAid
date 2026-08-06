
# @summary Helix Git Connector
#
# @param version The version of the Perforce installation. Defaults to $::role::projectmanagement::perforce::version.
#
# @param repos_dir The directory for repositories. Defaults to '/opt/perforce/git-connector/repos'.
#
# @param gconn_log_file The log file for the git connector. Defaults to "${log_dir}/gconn.log" of the Perforce role.
#
# @param p4gc_log_file The log file for the p4gc. Defaults to "${log_dir}/p4gc.log" of the Perforce role.
#
# @param __blendable Whether the configuration is blendable. No default value.
#
# @groups versioning version
#
# @groups paths repos_dir
#
# @groups logging gconn_log_file, p4gc_log_file
#
# @groups configuration __blendable
#
class role::projectmanagement::perforce::git_connector (
  Perforce::Version    $version        = $::role::projectmanagement::perforce::version,
  Stdlib::Absolutepath $repos_dir      = '/opt/perforce/git-connector/repos',
  Perforce::LogFile    $gconn_log_file = "${::role::projectmanagement::perforce::log_dir}/gconn.log",
  Perforce::LogFile    $p4gc_log_file  = "${::role::projectmanagement::perforce::log_dir}/p4gc.log",
  Boolean              $__blendable,
) inherits ::role::projectmanagement::perforce {

  confine(!('role::projectmanagement::perforce' in $::obmondo_classes),
          'This role requires the Perforce role to also be used.')

  'profile::projectmanagement::perforce::git_connector'.contain
}
