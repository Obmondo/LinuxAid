# VNC Server
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
