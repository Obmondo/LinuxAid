
# @summary Class for managing the Murmur roleclass
#
# @param password The password for the Murmur server. Defaults to undef.
#
# @param port The port on which the server will run. Defaults to 64738.
#
# @param host The host address for the server. Defaults to undef.
#
# @param register_name The name used for server registration. Defaults to 'Mumble Server'.
#
# @param bandwidth The maximum bandwidth for the server. Defaults to 72000.
#
# @param max_users The maximum number of users allowed. Defaults to 100.
#
# @param text_length_limit The length limit for text messages. Defaults to 5000.
#
# @param autoban_attempts The number of attempts before banning a user. Defaults to 10.
#
# @param autoban_time_frame The time frame for autoban attempts in seconds. Defaults to 120.
#
# @param autoban_time The duration of the ban in seconds. Defaults to 300.
#
# @param allow_html Whether to allow HTML in messages. Defaults to true.
#
# @param welcome_text The welcome text displayed to users. Defaults to 'Welcome to this server running Murmur.\n Enjoy your stay!\n'
#
# @param user The user under which the service will run. Defaults to 'mumble-server'.
#
# @param group The group under which the service will run. Defaults to 'mumble-server'.
#
# @param database_path The path to the database file. Defaults to '/var/lib/mumble-server/mumble-server.sqlite'.
#
# @param log_path The path to the log file. Defaults to '/var/log/mumble-server/mumble-server.log'.
#
# @param log_days The number of days to keep logs. Defaults to 31.
#
# @param ssl_cert The path to the SSL certificate. Defaults to undef.
#
# @param ssl_key The path to the SSL key. Defaults to undef.
#
# @groups connection port, host, ssl_cert, ssl_key
#
# @groups registration register_name, password
#
# @groups server_limits bandwidth, max_users, text_length_limit
#
# @groups security autoban_attempts, autoban_time_frame, autoban_time
#
# @groups appearance allow_html, welcome_text
#
# @groups execution user, group, database_path, log_path, log_days
#
class role::communication::murmur (
  Optional[String] $password               = undef,
  Stdlib::Port $port                        = 64738,
  Optional[Eit_types::Host] $host          = undef,
  String $register_name                     = 'Mumble Server',
  Integer[0, default] $bandwidth           = 72000,
  Integer[1, default] $max_users           = 100,
  Integer[1, default] $text_length_limit   = 5000,
  Integer[0, default] $autoban_attempts    = 10,
  Integer[0, default] $autoban_time_frame  = 120,
  Integer[0, default] $autoban_time        = 300,
  Boolean $allow_html                       = true,
  String $welcome_text                     = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',
  Eit_types::User $user                    = 'mumble-server',
  Eit_types::Group $group                  = 'mumble-server',
  Stdlib::Absolutepath $database_path      = '/var/lib/mumble-server/mumble-server.sqlite',
  Stdlib::Absolutepath $log_path           = '/var/log/mumble-server/mumble-server.log',
  Integer[1, default] $log_days            = 31,
  Optional[Stdlib::Absolutepath] $ssl_cert = undef,
  Optional[Stdlib::Absolutepath] $ssl_key  = undef,
) inherits role::communication {

  class { '::profile::communication::murmur':
    password           => $password,
    port               => $port,
    host               => $host,
    register_name      => $register_name,
    bandwidth          => $bandwidth,
    max_users          => $max_users,
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
