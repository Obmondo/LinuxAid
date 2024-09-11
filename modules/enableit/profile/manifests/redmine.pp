# Redmine profile
class profile::redmine (
  $servername,
  $serveralias = undef,
  Enum['mysql2','postgresql'] $db = 'mysql2',
  Boolean $setupdb = true,
) {

  $passenger_version = $::operatingsystemmajrelease ? {
    6       => 4,
    default => 5,
  }

  class { '::profile::web::apache':
    http    => true,
    https   => false,
    vhosts  => {},
    modules => [],
    ciphers => 'default',
  }

  -> class { '::passenger':
    passenger_version => $passenger_version,
  }

  if $setupdb {
    case $db {
      'mysql2': {
        class { '::profile::mysql' :
          webadmin => false,
        }
      }
      'postgresql': {
        class { 'profile::db::pgsql':
          listen_address     => '127.0.0.1',
          max_connections    => 300,
          allow_remote_hosts => [],
        }
      }
      default: {
        fail("Unknown db argument given: ${db}.")
      }
    }
  }

  class { '::redmine':
    version          => '3.3.0',
    database_adapter => $db,
  }

  apache::vhost { $servername:
    port          => '80',
    docroot       => '/var/www/html/redmine/public',
    serveraliases => $serveralias,
  }
}
