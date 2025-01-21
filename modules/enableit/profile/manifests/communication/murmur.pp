# Mumble fails on lxc because of avahi-daemon which fails getting installed under lxc.
# Here is the work around.
# https://lists.linuxcontainers.org/pipermail/lxc-users/2016-January/010791.html
class profile::communication::murmur (
  Optional[String] $password               = undef,
  Stdlib::Port $port                    = 64738,
  Optional[Eit_types::Host] $host          = undef,
  String $register_name                    = 'Mumble Server',
  Integer[0, default] $bandwidth           = 72000,
  Integer[1, default] $max_users           = 100,
  Integer[1, default] $text_length_limit   = 5000,
  Integer[0, default] $autoban_attempts    = 10,
  Integer[0, default] $autoban_time_frame  = 120,
  Integer[0, default] $autoban_time        = 300,
  Boolean $allow_html                      = true,
  String $welcome_text                     = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',

  Eit_types::User $user                    = 'mumble-server',
  Eit_types::Group $group                  = 'mumble-server',
  Stdlib::Absolutepath $database_path      = '/var/lib/mumble-server/mumble-server.sqlite',
  Stdlib::Absolutepath $log_path           = '/var/log/mumble-server/mumble-server.log',
  Integer[1, default] $log_days            = 31,
  Optional[Stdlib::Absolutepath] $ssl_cert = undef,
  Optional[Stdlib::Absolutepath] $ssl_key  = undef,
) inherits profile {

  ['udp', 'tcp'].map |$protocol| {
    firewall { "000 allow murmur ${protocol}":
      proto => $protocol,
      port  => $port,
      jump  => 'accept',
    }
  }

  class { '::mumble':
    password           => $password,
    port               => $port,
    host               => $host,
    register_name      => $register_name,
    bandwidth          => $bandwidth,
    users              => $max_users,
    text_length_limit  => $text_length_limit,
    autoban_attempts   => $autoban_attempts,
    autoban_time_frame => $autoban_time_frame,
    autoban_time       => $autoban_time,
    allow_html         => $allow_html,
    welcome_text       => $welcome_text,

    user               => $user,
    group              => $group,
    database_path      => $database_path,
    log_path           => $log_path,
    log_days           => $log_days,
    ssl_cert           => $ssl_cert,
    ssl_key            => $ssl_key,
  }
}
