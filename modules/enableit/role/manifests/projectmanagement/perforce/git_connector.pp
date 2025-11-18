
# @summary Helix Git Connector
#
# @param version The version of the Perforce installation. Defaults to $::role::projectmanagement::perforce::version.
#
# @param service_port The port on which the Perforce service is running. Defaults to $::role::projectmanagement::perforce::service_port.
#
# @param p4_gconn_user The user for the Perforce git connector. Defaults to 'gconn-user'.
#
# @param git_user_home The home directory for the git user. Defaults to '/var/lib/git'.
#
# @param gconn_dir The directory for the git connector. Defaults to '/opt/perforce/git-connector'.
#
# @param repos_dir The directory for repositories. Defaults to "${gconn_dir}/repos".
#
# @param log_dir The directory for logs. Defaults to $::role::projectmanagement::perforce::log_dir.
#
# @param gconn_log_file The log file for the git connector. Defaults to "${log_dir}/gconn.log".
#
# @param gconn_log_level The log level for the git connector. Defaults to 1.
#
# @param p4gc_log_file The log file for the p4gc. Defaults to "${log_dir}/p4gc.log".
#
# @param p4gc_log_level The log level for the p4gc. Defaults to 1.
#
# @param $__blendable
# Whether the configuration is blendable. No default value.
#
class role::projectmanagement::perforce::git_connector (
  Perforce::Version    $version         = $::role::projectmanagement::perforce::version,
  Stdlib::Port         $service_port    = $::role::projectmanagement::perforce::service_port,
  Eit_types::User      $p4_gconn_user   = 'gconn-user',
  Stdlib::Absolutepath $git_user_home   = '/var/lib/git',
  Stdlib::Absolutepath $gconn_dir       = '/opt/perforce/git-connector',
  Stdlib::Absolutepath $repos_dir       = "${gconn_dir}/repos",
  Stdlib::Absolutepath $log_dir         = $::role::projectmanagement::perforce::log_dir,
  Perforce::LogFile    $gconn_log_file  = "${log_dir}/gconn.log",
  Perforce::LogLevel   $gconn_log_level = 1,
  Perforce::LogFile    $p4gc_log_file   = "${log_dir}/p4gc.log",
  Perforce::LogLevel   $p4gc_log_level  = 1,
  Boolean              $__blendable,
) inherits ::role::projectmanagement::perforce {

  confine(!('role::projectmanagement::perforce' in $::obmondo_classes),
          'This role requires the Perforce role to also be used.')

  'profile::projectmanagement::perforce::git_connector'.contain
}
