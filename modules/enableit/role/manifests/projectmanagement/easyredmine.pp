# Setup easyredmine
# Partially broken, because redmine module is not maintained any more.
# We might have to patch to support easyredmine as well.
# Currently it tries to download redmine from different URL
# So what we need to do is
# Take over the redmine plugin
# Add support for easyredmine
# puppet 6 style
# Any more ?
class role::projectmanagement::easyredmine (
  Stdlib::Fqdn                $servername,
  # NOTE: Local filesystem path where the easyredmine zip file has been placed manually,
  # BEFORE running puppet. Necessary as one cannot just download easyredmine.
  Stdlib::Unixpath            $location,
  Variant[
    Array[Stdlib::Fqdn],
    Stdlib::Fqdn
  ]                           $serveralias        = $servername,
  Enum[
    'role::db::mysql',
    'role::db::pgsql'
  ]                           $database           = 'role::db::pgsql',
  Eit_types::Version          $version            = '3.3.0',
  Optional[Hash]              $plugins            = {},
  Optional[String]            $custom_fragment    = '',
) inherits role::projectmanagement {

  $_database = $database ? {
    'role::db::mysql' => 'mysql2',
    'role::db::pgsql' => 'postgresql'
  }

  profile::projectmanagement::easyredmine.contain

  $database.contain
}
