# vncserver
class profile::software::vncserver (
  Boolean           $enable      = $common::software::vncserver::enable,
  Optional[Boolean] $noop_value  = $common::software::vncserver::noop_value,
  Hash[Integer, Struct[{
    session  => Enum['gnome', 'kde', 'xfce', 'lxde'],
    name     => String,
    geometry => Enum['2000x1200', '1280x1024', '1920x1080', '1920x1200'],
  }]]               $vnc_session = $common::software::vncserver::vnc_session,
) {

  Package {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  $vnc_session.each | $port, $value| {
    class { 'vnc::server':
      vnc_servers     => {
        $value['name']    => {
        'displaynumber'   => "$port",
        'user_can_manage' =>  true,
        'comment'         => "vnc session for ${value['name']}",
        },
      },
      manage_services => $enable,
      config_defaults => {
        'session'  => $value['session'],
        'geometry' => $value['geometry'],
      },
    }

    $_port = $port + 5900

    firewall_multi {"100 allow vncserver port ${_port}":
      jump    => 'accept',
      dport   => "$_port",
      proto   => 'tcp',
    }
  }
}
