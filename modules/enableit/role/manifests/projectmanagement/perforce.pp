# Perforce version control system
class role::projectmanagement::perforce (
  Eit_types::User           $user              = 'perforce',
  Stdlib::Absolutepath      $service_root      = '/opt/perforce/p4root',
  Eit_types::SimpleString   $service_name      = 'perforce',
  Boolean                   $ssl               = true,
  Stdlib::Absolutepath      $service_ssldir    = '/etc/perforce/ssl',
  Stdlib::Port              $service_port      = 1666,
  Eit_types::Password       $service_password,
  Optional[String]          $license_content   = undef,
  Stdlib::Host              $hostname          = $facts['hostname'],
  Perforce::Version         $version,
  Stdlib::Absolutepath      $log_dir           = '/var/log/perforce',
  Perforce::LogLevel        $log_level         = 1,

  Boolean                   $icmanage          = false,
  Boolean                   $git_connector     = true,
  Eit_types::User           $admin_user        = 'p4admin',
  Eit_types::Password       $admin_password,
  Eit_types::User           $operator_user     = 'p4operator',
  Eit_types::Password       $operator_password,

  Stdlib::Absolutepath      $backup_dir        = $::common::backup::dump_dir,
  Eit_types::Duration::Days $backup_retention  = 7,
) inherits ::role {

  confine($facts.dig('os', 'family') != 'RedHat', 'Only Redhat-based distributions are supported')

  'profile::projectmanagement::perforce'.contain

  if git_connector {
    include role::projectmanagement::perforce::git_connector
  }

  if icmanage {
    include role::projectmanagement::perforce::icmanage
  }
}
