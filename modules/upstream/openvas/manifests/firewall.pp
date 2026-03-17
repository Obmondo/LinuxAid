# @summary Manages firewall exposure for the OpenVAS web interface.
#
# @param install
#   Whether OpenVAS is installed.
#
# @param expose
#   Whether the OpenVAS web UI should be exposed.
#
# @param web_port
#   Firewall TCP port to open for the OpenVAS web UI.
#
class openvas::firewall (
  Boolean             $install  = $openvas::install,
  Boolean             $expose   = $openvas::expose,
  Integer[1, 65535]   $web_port = $openvas::web_port,
) {
  firewall_multi { '000 allow openvas web interface':
    ensure => stdlib::ensure($install and $expose),
    dport  => $web_port,
    proto  => 'tcp',
    jump   => 'accept',
  }
}
