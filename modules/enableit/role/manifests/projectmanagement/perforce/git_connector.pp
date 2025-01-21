# Helix Git Connector
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

  confine(!('role::projectmanagement::perforce' in $facts['obmondo_classes']),
            'This role requires the Perforce role to also be used.')

  'profile::projectmanagement::perforce::git_connector'.contain
}
