
# @summary Class for managing the LAMP role
#
# @param db The database role to use. Defaults to 'role::db::mysql'.
#
# @param webserver The web server to use. Defaults to 'role::web::apache'.
#
# @param php The PHP implementation to use. Defaults to 'role::appeng::phpfpm'.
#
# @groups database db
#
# @groups server webserver, php
#
class role::webframeworks::lamp (
  Enum['role::db::mysql', 'role::db::pgsql']  $db        = 'role::db::mysql',
  Enum['role::web::apache', 'role::web::nginx']  $webserver = 'role::web::apache',
  Enum['role::appeng::phpfpm', 'role::appeng::mod_php']  $php       = 'role::appeng::phpfpm',
) inherits role::webframeworks {

  # Setup Webserver
  $webserver.contain

  # Setup PHP
  #$php.contain

  # Setup Database
  $db.contain
}
