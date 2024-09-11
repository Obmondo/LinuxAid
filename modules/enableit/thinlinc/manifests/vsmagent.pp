# Configure ThinLinc VSM (VNC Session Manager) agent
#
class thinlinc::vsmagent (
  Stdlib::Host                  $master_hostname     = $::thinlinc::vsmagent_master_hostname,
  Optional[Array[Stdlib::Host]] $allowed_clients     = $::thinlinc::vsmagent_allowed_clients,
  Boolean                       $make_homedir        = $::thinlinc::vsmagent_make_homedir,
  Stdlib::FileMode              $make_homedir_mode   = $::thinlinc::vsmagent_make_homedir_mode,
  String                        $default_geometry    = $::thinlinc::vsmagent_default_geometry,
  Boolean                       $single_signon       = $::thinlinc::vsmagent_single_signon,
  Array[String]                 $xserver_args        = $::thinlinc::vsmagent_xserver_args,
  ThinLinc::XAuthorityLocation  $xauthority_location = $::thinlinc::vsmagent_xauthority_location,
  Optional[Stdlib::Host]        $agent_hostname      = $::thinlinc::vsmagent_agent_hostname,
  Stdlib::Port                  $max_session_port    = $::thinlinc::vsmagent_max_session_port,
  Stdlib::Port                  $lowest_user_port    = $::thinlinc::vsmagent_lowest_user_port,
  Integer[0,default]            $xvnc_start_timeout  = $::thinlinc::vsmagent_xvnc_start_timeout,
  Stdlib::Port                  $listen_port         = $::thinlinc::vsmagent_listen_port,
  Optional[Boolean]             $enable_ha           = $::thinlinc::vsmserver_enable_ha,
  Hash[String, String]          $default_environment = $::thinlinc::vsmagent_default_environment,
  Integer[1,default]            $display_min         = $::thinlinc::vsmagent_display_min,
  Integer[1,default]            $display_max         = $::thinlinc::vsmagent_display_max,
  Array[Stdlib::IP::Address]    $allowed_hosts       = $::thinlinc::vsmagent_allowed_hosts,


  Boolean                $log_to_file       = $::thinlinc::vsmagent_log_to_file,
  Stdlib::Absolutepath   $log_dir           = $::thinlinc::vsmagent_log_dir,
  Boolean                $log_to_syslog     = $::thinlinc::vsmagent_log_to_syslog,
  String                 $syslog_facility   = $::thinlinc::vsmagent_syslog_facility,
  Stdlib::Absolutepath   $syslog_socket     = $::thinlinc::vsmagent_syslog_socket,
  Optional[Stdlib::Host] $syslog_host       = $::thinlinc::vsmagent_syslog_host,
  ThinLinc::LogLevel     $default_log_level = $thinlinc::default_log_level,
  ThinLinc::LogLevel     $extcmd_log_level  = $::thinlinc::vsmagent_extcmd_log_level,
  ThinLinc::LogLevel     $session_log_level = $::thinlinc::vsmagent_session_log_level,
  ThinLinc::LogLevel     $xmlrpc_log_level  = $::thinlinc::vsmagent_xmlrpc_log_level,
) inherits ::thinlinc {

  confine($display_min >= $display_max,
          '`display_max` must be larger than `display_min`')

  thinlinc::ensure_log_dir($log_dir)

  $_config_file = "${thinlinc::install_dir}/etc/conf.d/vsmagent.hconf"

  file { $_config_file:
    ensure  => 'file',
    content => epp('thinlinc/conf.d/vsmagent.hconf.epp'),
    notify  => Service['vsmagent'],
  }

  $_x11_port_max = 6000+$display_max

  firewall { '200 allow x11 inbound traffic for tcp display forwarding':
    jump   => 'accept',
    dport  => ["6000-${_x11_port_max}"],
    proto  => 'tcp',
    source => if $allowed_hosts.count > 0{
      $allowed_hosts
    },
  }

  if $enable_ha {

    firewall_multi { '200 allow vsmagent for loadinfo':
      jump   => 'accept',
      dport  => $listen_port,
      proto  => 'tcp',
      source => if $allowed_clients.count {
        $allowed_clients
      },
    }
  }

  if $log_to_file {
    logrotate::rule { 'thinlinc-vsm-agent':
      path         => "${log_dir}/vsmagent.log",
      copytruncate => true,
    }
  }

}
