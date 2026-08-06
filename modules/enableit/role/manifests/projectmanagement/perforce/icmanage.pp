
# @summary Class for managing ICManage on top of Perforce
#
# @param version The version of ICManage. No default.
#
# @param manage_db Whether to manage the database. Defaults to false.
#
# @param db_password The database password. No default.
#
# @param root_password The root password. No default.
#
# @param db_admin_password The database admin password. No default.
#
# @param access_mysql_from The IP CIDR allowed to access MySQL. Defaults to ['0.0.0.0/0'].
#
# @param backup_dir The backup directory. No default.
#
# @param __blendable This parameter allows blending. No default.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups db db_password, db_admin_password, access_mysql_from
#
# @groups install version
#
# @groups credentials root_password, encrypt_params
#
# @groups config __blendable, manage_db, backup_dir
# 
# @encrypt_params db_password, root_password, db_admin_password
# 
class role::projectmanagement::perforce::icmanage (
  Integer[0,default]       $version,
  Eit_types::Password      $db_password,
  Eit_types::Password      $root_password,
  Eit_types::Password      $db_admin_password,
  Stdlib::Absolutepath     $backup_dir,
  Boolean                  $__blendable,

  Boolean                  $manage_db          = false,
  Array[Eit_types::IPCIDR] $access_mysql_from  = ['0.0.0.0/0'],

  Eit_types::Encrypt::Params $encrypt_params = [
    'db_password',
    'root_password',
    'db_admin_password',
  ]

) inherits ::role::projectmanagement::perforce {

  confine(!('role::projectmanagement::perforce' in $::obmondo_classes),
            'This role requires the Perforce role to also be used.')

  contain role::projectmanagement::perforce::icmanage::manage_db

  'profile::projectmanagement::perforce::icmanage'.contain
}
