# This class will install the Mumble server component, Murmur.
class mumble (
  $autostart       = true,      # Start server at boot
  $ppa             = false,     # Use PPA
  $snapshot        = false,     # PPA only: use snapshot over release
  $libicu_fix      = false,     # install libicu-dev to fix dependency
  $server_password = undef,     # Supervisor account password
  $version         = installed, # Version of mumble to install

  # The following parameters affect mumble-server.ini through a template
  # For more info, see http://mumble.sourceforge.net/Murmur.ini
  $register_name      = 'Mumble Server',
  $password           = undef,  # General entrance password
  $port               = 64738,
  $host               = undef,
  $user               = 'mumble-server',
  $group              = 'mumble-server',
  $bandwidth          = 72000,
  $users              = 100,
  $text_length_limit  = 5000,
  $autoban_attempts   = 10,
  $autoban_time_frame = 120,
  $autoban_time       = 300,
  $database_path      = '/var/lib/mumble-server/mumble-server.sqlite',
  $log_path           = '/var/log/mumble-server/mumble-server.log',
  $allow_html         = true,
  $log_days           = 31,
  $ssl_cert           = undef,
  $ssl_key            = undef,
  $welcome_text       = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',
) {

  case $::operatingsystem {
    'Debian': {
    }

    'Ubuntu': {
      if $ppa {
        apt::ppa { 'ppa:mumble/snapshot':
          before => Package['mumble-server'],
        }
        apt::ppa { 'ppa:mumble/release':
          before => Package['mumble-server'],
        }
      }

      if $::lsbmajdistrelease == '12.04' {
        # Missing dependency for 12.04 with PPA
        if $libicu_fix {
          package { 'libicu-dev':
            before => Package['mumble-server'],
          }
        }
      }
    }

    default: {
      fail("${::operatingsystem} is not yet supported.")
    }
  }

  package { 'mumble-server':
    ensure => $version,
  }

  group { $group:
    require => Package['mumble-server'],
  }

  user { $user:
    gid     => $group,
    require => [Group[$group], Package['mumble-server']],
  }

  file { '/etc/mumble-server.ini' :
    owner   => $user,
    group   => $group,
    replace => true,
    content => template('mumble/mumble-server.erb'),
    require => Package['mumble-server'],
  }

  service { 'mumble-server':
    ensure    => running,
    enable    => $autostart,
    subscribe => File['/etc/mumble-server.ini'],
  }

  if $server_password != undef {
    exec { 'mumble_set_password':
      command => "/usr/sbin/murmurd -supw ${server_password}",
      require => Service['mumble-server'],
    }
  }
}
