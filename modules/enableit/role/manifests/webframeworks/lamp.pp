
# @summary Class for managing the LAMP role
#
# @param db The database role to use. Defaults to 'role::db::mysql'.
#
# @param webserver The web server to use. Defaults to 'role::web::apache'.
#
# @groups database db
#
# @groups server webserver
#
class role::webframeworks::lamp (
  Enum['role::db::mysql', 'role::db::pgsql']  $db        = 'role::db::mysql',
  Enum['role::web::apache', 'role::web::nginx']  $webserver = 'role::web::apache',
) inherits role::webframeworks {

  # Setup Webserver
  $webserver.contain

  # Setup Database
  $db.contain
}
