
# @summary Class for managing the Piwik web role
#
# @param hostname The hostname for the Piwik application.
#
# @param database_password The password for the database.
#
# @param variant The variant of PHP to use. Defaults to '::role::appeng::mod_php'.
#
# @param database The database type to use. Defaults to '::role::db::mysql'.
#
# @param force_https Whether to force HTTPS. Defaults to false.
#
# @param use_forwarded_for Whether to use the forwarded for header. Defaults to false.
#
# @param use_forwarded_host Whether to use the forwarded host header. Defaults to false.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class role::web::piwik (
  String $hostname,
  Eit_types::Password $database_password,

  Enum['::role::db::mysql'] $database           = '::role::db::mysql',
  Boolean                   $force_https        = false,
  Boolean                   $use_forwarded_for  = false,
  Boolean                   $use_forwarded_host = false,

  Enum['::role::appeng::mod_php', '::role::appeng::phpfpm'] $variant = '::role::appeng::mod_php',

  Eit_types::Encrypt::Params $encrypt_params = [
    'database_password',
  ],

) inherits ::role::web {

  class { '::role::web::php':
    variant => $variant,
  }

  class { $database: }

  class { 'piwik':
    version            => 'latest',
    user               => 'www-data',
    force_https        => $force_https,
    use_forwarded_for  => $use_forwarded_for,
    use_forwarded_host => $use_forwarded_host,
  }

  apache::vhost { $hostname:
    port    => '80',
    docroot => $::piwik::path,
    require => Class['piwik'],
  }

  if $database == '::role::db::mysql' {
    mysql::db { 'piwik':
      user     => 'piwik',
      password => $database_password,
      host     => 'localhost',
      grant    => ['ALL'],
    }
  } else {
    fail('We should probably do something here..')
  }
}
