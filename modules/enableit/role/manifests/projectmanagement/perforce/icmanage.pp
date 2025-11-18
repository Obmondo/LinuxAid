
# @summary Class for managing ICManage on top of Perforce
#
# @param version The version of ICManage. No default.
#
# @param install_path The installation path. Defaults to '/opt/icmanage'.
#
# @param hostname The hostname. Defaults to the value of $facts['networking']['hostname'].
#
# @param manage_db Whether to manage the database. Defaults to false.
#
# @param db_user The database username. Defaults to 'icm'.
#
# @param db_password The database password. No default.
#
# @param root_password The root password. No default.
#
# @param db_backup Whether to backup the database. No default.
#
# @param db_admin_user The database admin username. Defaults to 'icmadmin'.
#
# @param db_admin_password The database admin password. No default.
#
# @param db_charset The database charset. Defaults to 'utf8'.
#
# @param db_collate The database collate. Defaults to 'utf8_general_ci'.
#
# @param config_file The path to the configuration file. Defaults to '/etc/icmanage/icmPm.cfg'.
#
# @param access_mysql_from The IP CIDR allowed to access MySQL. Defaults to ['0.0.0.0/0'].
#
# @param mysql_version The MySQL version. Defaults to '5.5'.
#
# @param backup_dir The backup directory. No default.
#
# @param __blendable This parameter allows blending. No default.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class role::projectmanagement::perforce::icmanage (
  Integer[0,default]       $version,
  Eit_types::Password      $db_password,
  Eit_types::Password      $root_password,
  Boolean                  $db_backup,
  Eit_types::Password      $db_admin_password,
  Stdlib::Absolutepath     $backup_dir,
  Boolean                  $__blendable,

  Stdlib::Absolutepath     $install_path       = '/opt/icmanage',
  Stdlib::Host             $hostname           = $facts['networking']['hostname'],
  Boolean                  $manage_db          = false,
  Eit_types::SimpleString  $db_user            = 'icm',
  Eit_types::SimpleString  $db_admin_user      = 'icmadmin',
  Eit_types::SimpleString  $db_charset         = 'utf8',
  Eit_types::SimpleString  $db_collate         = 'utf8_general_ci',
  Stdlib::Absolutepath     $config_file        = '/etc/icmanage/icmPm.cfg',
  Array[Eit_types::IPCIDR] $access_mysql_from  = ['0.0.0.0/0'],
  String                   $mysql_version      = '5.5',

  Eit_types::Encrypt::Params $encrypt_params = [
    'db_password',
    'root_password',
    'db_admin_password',
  ]

) inherits ::role::projectmanagement::perforce {

  confine(!('role::projectmanagement::perforce' in $::obmondo_classes),
            'This role requires the Perforce role to also be used.')
  'profile::projectmanagement::perforce::icmanage'.contain
}
