# @summary Map defined VNC servers into NOVNC client
#
# @param vnc_server_hostname
#   Hostname to use as the default server target
# @param vnc_servers
#   Hash of vnc_servers to export.
#   You probably should just let inheritance do the work here
# @example
#   include vnc::server::export::novnc
class vnc::server::export::novnc (
  # lint:ignore:parameter_types
  String $vnc_server_hostname = 'localhost',
  Hash $vnc_servers = $vnc::server::vnc_servers,
  # lint:endignore
) inherits vnc::server {
  $connections = $vnc_servers.reduce({}) |$memo, $user_info| {
    $memo + { $user_info[0] => "${vnc_server_hostname}:${user_info[1]['displaynumber']}" }
  }

  class { 'novnc':
    vnc_servers => $connections,
  }
}
