
# @summary Class for managing the Piwik web role
#
# @param hostname The hostname for the Piwik application.
#
# @param database_password The password for the database.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups network hostname
#
# @groups database database_password, encrypt_params
#
# @encrypt_params database_password
#
class role::web::piwik (
  String $hostname,
  Eit_types::Password $database_password,

  Eit_types::Encrypt::Params $encrypt_params = [
    'database_password',
  ],

) inherits ::role::web {

  class { '::role::appeng::phpfpm': }

  class { '::role::db::mysql': }

  class { 'piwik':
    version            => 'latest',
    user               => 'www-data',
    force_https        => false,
    use_forwarded_for  => false,
    use_forwarded_host => false,
  }

  apache::vhost { $hostname:
    port    => '80',
    docroot => $::piwik::path,
    require => Class['piwik'],
  }

  mysql::db { 'piwik':
    user     => 'piwik',
    password => $database_password,
    host     => 'localhost',
    grant    => ['ALL'],
  }
}
