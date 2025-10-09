#
# @summary This class manages mumble on Debian based systems.
#
# @example Install mumble and configure an entrance password
#   class { 'mumble':
#     password => 'Fo0b@rr',
#   }
#
# @param autostart start server at boot.
# @param ppa use Ubuntu PPA instead default APT repos.
# @param snapshot (PPA only) use snapshot over release.
# @param libicu_fix install libicu-dev to fix dependency.
# @param server_password supervisor account password (mumble admin).
# @param version configure the version of mumble to install.
# @param register_name muble server name. (This parameter affect mumble-server.ini through a template. For more info, see http://mumble.sourceforge.net/Murmur.ini)
# @param password general entrance password.
# @param port port to bind TCP and UDP sockets to.
# @param host IP or hostname to bind to. (If this is left blank (default), Murmur will bind to all available addresses).
# @param user username used to start mumble.
# @param group mumble server group
# @param bandwidth maximum bandwidth (in bits per second) clients are allowed).
# @param users maximum number of concurrent clients allowed.
# @param text_length_limit maximum length of text messages in characters. 0 for no limit.
# @param autoban_attempts how many login attempts do we tolerate from one IP? (0 to disable).
# @param autoban_time_frame time interval (0 to disable).
# @param autoban_time bantime duration in seconds (0 to disable).
# @param database_path path to database.
#   Allowed values: absolute path
# @param log_path path to logfile
#   Allowed values: absolute path
# @param allow_html allow clients to use HTML in messages, user comments and channel descriptions?
# @param log_days log entries in an internal database (set to 0 to keep forever, or -1 to disable logging to the DB).
# @param ssl_cert ssl certificate.
# @param ssl_key key file.
# @param welcome_text a welcome formated text.
#
class mumble (
  $autostart          = true,      # Start server at boot
  $ppa                = false,     # Use PPA
  $snapshot           = false,     # PPA only: use snapshot over release
  $libicu_fix         = false,     # install libicu-dev to fix dependency
  $server_password    = undef,     # Supervisor account password
  $version            = installed, # Version of mumble to install

  # The following parameters affect mumble-server.ini through a template
  # For more info, see http://mumble.sourceforge.net/Murmur.ini
  $register_name      = 'Mumble Server',
  $password           = '',    # General entrance password
  $port               = 64738,
  $host               = '',
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
  $ssl_cert           = '',
  $ssl_key            = '',
  $welcome_text       = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',
) {
  case $facts['os']['name'] {
    'Debian','Ubuntu': {
      if $ppa {
        apt::ppa { 'ppa:mumble/snapshot':
          # ensure => $snapshot ? { true => 'present', false => 'absent' },
          before => Package['mumble-server'],
        }
        apt::ppa { 'ppa:mumble/release':
          # ensure => $snapshot ? { false => 'present', true => 'absent' },
          before => Package['mumble-server'],
        }
      }
      else {
        # apt::ppa { ['ppa:mumble/snapshot', 'ppa:mumble/release']:
        #   ensure => 'absent'
        # }
      }
      # Missing dependency for 12.04 with PPA
      if $libicu_fix {
        package { 'libicu-dev':
          before => Package['mumble-server'],
        }
      }
    }
    default: {
      fail("${facts['os']['name']} is not yet supported.")
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
      command  => "/usr/sbin/murmurd -supw ${shell_escape($server_password)} 2>&1 | /bin/grep 'Superuser password set on server' && /usr/bin/touch /etc/mumble-server-puppet", # lint:ignore:140chars
      creates  => '/etc/mumble-server-puppet',
      require  => Service['mumble-server'],
      provider => 'shell',
    }
  }
}
