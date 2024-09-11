# Piwik web role
class role::web::piwik (
  String $hostname,
  Eit_types::Password $database_password,
  Enum['::role::appeng::mod_php', '::role::appeng::phpfpm'] $variant = '::role::appeng::mod_php',
  Enum['::role::db::mysql'] $database = '::role::db::mysql',
  Boolean $force_https = false,
  Boolean $use_forwarded_for = false,
  Boolean $use_forwarded_host = false,
) inherits ::role::web {

  class { '::role::web::php':
    variant => $variant,
  }

  class { $database:  }

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
