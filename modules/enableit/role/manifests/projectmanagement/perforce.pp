
# @summary Class for managing the Perforce version control system
#
# @param service_root The root directory for the Perforce service. Defaults to '/opt/perforce/p4root'.
#
# @param ssl Whether to use SSL for the Perforce service. Defaults to true.
#
# @param service_port The port for the Perforce service. Defaults to 1666.
#
# @param service_password The password for the Perforce service.
#
# @param hostname The hostname for the Perforce service. Defaults to the system's hostname.
#
# @param version The version of the Perforce service.
#
# @param log_dir The directory for Perforce logs. Defaults to '/var/log/perforce'.
#
# @param icmanage Whether to manage IC. Defaults to false.
#
# @param git_connector Whether to enable Git connector. Defaults to true.
#
# @param admin_user The admin user for the Perforce service. Defaults to 'p4admin'.
#
# @param admin_password The password for the admin user.
#
# @param operator_user The operator user for the Perforce service. Defaults to 'p4operator'.
#
# @param operator_password The password for the operator user.
#
# @param backup_dir The directory for backups. Defaults to the common backup directory.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups credentials service_password, admin_password, operator_password, encrypt_params
#
# @groups service service_root, service_port, ssl, version
#
# @groups users admin_user, operator_user
#
# @groups logging log_dir
#
# @groups features icmanage, git_connector
#
# @groups backup backup_dir
#
# @groups hostname hostname
#
# @encrypt_params service_password, admin_password, operator_password
#
class role::projectmanagement::perforce (
  Eit_types::Password       $service_password,
  Eit_types::Password       $admin_password,
  Eit_types::Password       $operator_password,
  Stdlib::Absolutepath      $service_root      = '/opt/perforce/p4root',
  Boolean                   $ssl               = true,
  Stdlib::Port              $service_port      = 1666,
  Stdlib::Host              $hostname          = $facts['networking']['hostname'],
  Perforce::Version         $version,
  Stdlib::Absolutepath      $log_dir           = '/var/log/perforce',
  Boolean                   $icmanage          = false,
  Boolean                   $git_connector     = true,
  Eit_types::User           $admin_user        = 'p4admin',
  Eit_types::User           $operator_user     = 'p4operator',
  Stdlib::Absolutepath      $backup_dir        = $::common::backup::dump_dir,

  Eit_types::Encrypt::Params $encrypt_params = [
    'service_password',
    'admin_password',
    'operator_password',
  ],

) inherits ::role {

  confine($facts['os']['family'] != 'RedHat', 'Only Redhat-based distributions are supported')

  'profile::projectmanagement::perforce'.contain

  if $git_connector {
    include role::projectmanagement::perforce::git_connector
  }

  if $icmanage {
    include role::projectmanagement::perforce::icmanage
  }
}
