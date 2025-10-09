# @api private
#
# @summary Ensure the VNC Server services are right
#
# @param manage_services
#   Should this class manage the vncserver services
# @param systemd_template_startswith
#   What does the vnc template service start with, not including the '@'
# @param systemd_template_endswith
#   What does the vnc template service end with, not including the '.'
# @param vnc_servers
#   See the server.pp documentation for structure
class vnc::server::service (
  # lint:ignore:parameter_types
  $manage_services         = $vnc::server::manage_services,

  $systemd_template_startswith = $vnc::server::systemd_template_startswith,
  $systemd_template_endswith   = $vnc::server::systemd_template_endswith,

  $vnc_servers = $vnc::server::vnc_servers
  # lint:endignore
) inherits vnc::server {
  assert_private()

  if $manage_services {
    $vnc_servers.keys.each |$username| {
      if 'ensure' in $vnc_servers[$username] {
        $ensure = $vnc_servers[$username]['ensure']
      } else {
        $ensure = 'running'
      }
      if 'enable' in $vnc_servers[$username] {
        $enable = $vnc_servers[$username]['enable']
      } else {
        $enable = true
      }

      unless 'displaynumber' in $vnc_servers[$username] {
        fail("You must set the 'displaynumber' property for ${username}'s vnc server")
      }

      # lint:ignore:140chars
      service { "${systemd_template_startswith}@:${vnc_servers[$username]['displaynumber']}.${systemd_template_endswith}":
        ensure => $ensure,
        enable => $enable,
      }
      # lint:endignore
    }
  }
}
