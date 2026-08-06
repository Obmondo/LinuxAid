# Mumble fails on lxc because of avahi-daemon which fails getting installed under lxc.
# Here is the work around.
# https://lists.linuxcontainers.org/pipermail/lxc-users/2016-January/010791.html
class profile::communication::murmur inherits profile {

  $port = 64738

  ['udp', 'tcp'].map |$protocol| {
    firewall { "000 allow murmur ${protocol}":
      proto => $protocol,
      port  => $port,
      jump  => 'accept',
    }
  }

  class { '::mumble':
    password           => undef,
    port               => $port,
    host               => undef,
    register_name      => 'Mumble Server',
    bandwidth          => 72000,
    users              => 100,
    text_length_limit  => 5000,
    autoban_attempts   => 10,
    autoban_time_frame => 120,
    autoban_time       => 300,
    allow_html         => true,
    welcome_text       => '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',

    user               => 'mumble-server',
    group              => 'mumble-server',
    database_path      => '/var/lib/mumble-server/mumble-server.sqlite',
    log_path           => '/var/log/mumble-server/mumble-server.log',
    log_days           => 31,
    ssl_cert           => undef,
    ssl_key            => undef,
  }
}
