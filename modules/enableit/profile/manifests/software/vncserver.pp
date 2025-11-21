# VNC Server
class profile::software::vncserver (
  Boolean                             $enable         = $common::software::vncserver::enable,
  Eit_types::Noop_Value                   $noop_value     = $common::software::vncserver::noop_value,
  Struct[{
    session  => Enum['gnome', 'kde', 'xfce', 'lxde', 'ubuntu'],
    geometry => Enum['2000x1200', '1280x1024', '1920x1080', '1920x1200'],
    localhost => Optional[Enum['yes', 'no']],
  }]                                  $config_defaults = $common::software::vncserver::config_defaults,
  Hash[String, Stdlib::Port]          $vnc_users       = $common::software::vncserver::vnc_users,
  Enum['vncserver', 'tigervncserver'] $systemd_service = $common::software::vncserver::systemd_service,
) {

  Package {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  if versioncmp($facts['os']['release']['full'], '24.04') >= 0 {
    $_config_defaults = functions::array_to_hash(
      $config_defaults.map |$key, $value| {
        {
          "\$${key}" => "'${value}';",
        }
      }
    )
  } else {
    $_config_defaults = $config_defaults
  }

  # Initialize an empty hash to store aggregated VNC server configurations
  $vnc_user_sessions = $vnc_users.reduce({}) |$memo, $options| {
    [$name, $port] = $options
    $memo + {
      $name => {
        displaynumber   => $port,
        user_can_manage => true,
        comment         => "vnc session for ${name}",
      }
    }
  }

  # Declare the vnc::server class using the aggregated VNC server configurations
  class { 'vnc::server':
    vnc_servers                 => $vnc_user_sessions,
    manage_services             => $enable,
    config_defaults             => $_config_defaults,
    systemd_template_startswith => $systemd_service,
  }

  # Manage firewall rules for each VNC session
  $vnc_users.each |$name, $port| {
    $_port = $port + 5900
    firewall_multi { "100 allow vncserver port ${_port}":
      jump  => 'accept',
      dport => $_port,
      proto => 'tcp',
    }
  }
}
