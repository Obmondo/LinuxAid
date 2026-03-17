# @summary Main class for managing OpenVAS via Docker Compose.
#
# @param install
#   Whether to install and manage the OpenVAS stack.
#
# @param expose
#   Whether the OpenVAS web UI should be exposed.
#
# @param compose_dir
#   Directory where the OpenVAS compose file is managed.
#
# @param feed_release
#   Greenbone feed release used by feed-related services.
#
# @param web_port
#   Firewall TCP port to open for the OpenVAS web UI.
#
# @param manage_docker
#   Whether to manage Docker engine with puppetlabs-docker.
#
class openvas (
  Boolean                $install        = true,
  Boolean                $expose         = true,
  Stdlib::Absolutepath   $compose_dir    = '/opt/openvas',
  String[1]              $feed_release   = '24.10',
  Integer[1, 65535]      $web_port       = 9392,
  Boolean                $manage_docker  = true,
) {
  if $manage_docker {
    contain docker
    contain docker::compose
  }

  contain openvas::compose
  contain openvas::firewall
}
