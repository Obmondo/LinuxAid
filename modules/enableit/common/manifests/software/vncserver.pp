# @summary Class for managing the VNC Server
#
# @param manage Whether to manage the VNC Server. Defaults to false.
#
# @param enable Whether to enable the VNC Server. Defaults to false.
#
# @param config_defaults The default configuration for the VNC server, including session and geometry. Defaults to an empty hash.
#
# @param vnc_users A hash of VNC users and their port configurations. Defaults to an empty hash.
#
# @param noop_value Optional boolean for noop mode. Defaults to false.
#
class common::software::vncserver (
  Boolean                                  $manage           = false,
  Boolean                                  $enable           = false,
  Struct[{
      session  => Enum['gnome', 'kde', 'xfce', 'lxde'],
      geometry => Enum['2000x1200', '1280x1024', '1920x1080', '1920x1200'],
  }]                                       $config_defaults  = {},
  Hash[String, Stdlib::Port]               $vnc_users        = {},
  Optional[Boolean]                        $noop_value       = false,
) inherits common {
  if $manage {
    contain profile::software::vncserver
  }
}
