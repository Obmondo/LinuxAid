# ICManage on top of Perforce
class role::projectmanagement::perforce::icmanage (
  Integer[0,default]       $version,
  Stdlib::Absolutepath     $install_path       = '/opt/icmanage',

  Stdlib::Host             $hostname           = $facts['networking']['hostname'],

  Boolean                  $manage_db          = false,
  Eit_types::SimpleString  $db_user            = 'icm',
  Eit_types::Password      $db_password,
  Eit_types::Password      $root_password,
  Boolean                  $db_backup,

  Eit_types::SimpleString  $db_admin_user      = 'icmadmin',
  Eit_types::Password      $db_admin_password,
  Eit_types::SimpleString  $db_charset         = 'utf8',
  Eit_types::SimpleString  $db_collate         = 'utf8_general_ci',

  Stdlib::Absolutepath     $config_file        = '/etc/icmanage/icmPm.cfg',
  Array[Eit_types::IPCIDR] $access_mysql_from  = ['0.0.0.0/0'],
  String                   $mysql_version      = '5.5',
  Stdlib::Absolutepath     $backup_dir,
  Boolean                  $__blendable,
) inherits ::role::projectmanagement::perforce {

  confine(!('role::projectmanagement::perforce' in $::obmondo_classes),
            'This role requires the Perforce role to also be used.')

  'profile::projectmanagement::perforce::icmanage'.contain
}
