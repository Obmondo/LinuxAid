# @summary Database settings for ICManage, used when `manage_db` is enabled
#
# @param db_backup Whether to backup the database. No default.
#
# @param db_charset The database charset. Defaults to 'utf8'.
#
# @param db_collate The database collate. Defaults to 'utf8_general_ci'.
#
# @param mysql_version The MySQL version. Defaults to '5.5'.
#
# @groups manage_db db_backup, db_charset, db_collate, mysql_version
#
class role::projectmanagement::perforce::icmanage::manage_db (
  Boolean                 $db_backup,
  Eit_types::SimpleString $db_charset    = 'utf8',
  Eit_types::SimpleString $db_collate    = 'utf8_general_ci',
  String                  $mysql_version = '5.5',
) {
}
