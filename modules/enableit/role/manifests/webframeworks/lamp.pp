# Lamp role
class role::webframeworks::lamp (
  Enum[
    'role::db::mysql',
    'role::db::pgsql'
  ]                          $db        = 'role::db::mysql',
  Enum[
    'role::web::apache',
    'role::web::nginx'
  ]                          $webserver = 'role::web::apache',
  Enum[
    'role::appeng::phpfpm',
    'role::appeng::mod_php'
  ]                          $php       = 'role::appeng::phpfpm',
) inherits role::webframeworks {

  # Setup Webserver
  $webserver.contain

  # Setup PHP
  #$php.contain

  # Setup Database
  $db.contain
}
