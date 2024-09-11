# VNC Server
class common::software::vncserver (
  Boolean           $manage      = false,
  Boolean           $enable      = false,
  Hash[Integer, Struct[{
    session  => Enum['gnome', 'kde', 'xfce', 'lxde'],
    name     => String,
    geometry => Enum['2000x1200', '1280x1024', '1920x1080', '1920x1200'],
  }]]               $vnc_session = {},
  Optional[Boolean] $noop_value  = false,
) inherits common {

  if $manage {
    contain profile::software::vncserver
  }
}
