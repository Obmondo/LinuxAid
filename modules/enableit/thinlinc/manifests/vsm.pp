# Configure ThinLinc VSM (VNC Session Manager)
#
class thinlinc::vsm (
  Stdlib::Port                  $server_port              = $::thinlinc::vsm_server_port,
  Stdlib::Port                  $agent_port               = $::thinlinc::vsm_agent_port,
  Stdlib::Port                  $vnc_port_base            = $::thinlinc::vsm_vnc_port_base,
  Stdlib::Port                  $tunnel_bind_base         = $::thinlinc::vsm_tunnel_bind_base,
  Integer                       $tunnel_slots_per_session = $::thinlinc::vsm_tunnel_slots_per_session,
  Array[Tuple[String, Integer]] $tunnel_services          = $::thinlinc::vsm_tunnel_services,
) inherits ::thinlinc {

  confine($tunnel_slots_per_session < $tunnel_services.size,
          '`tunnel_services` must be at least the number of items in `tunnel_slots_per_session`')

  file { "${thinlinc::install_dir}/etc/conf.d/vsm.hconf":
    ensure  => 'file',
    content => epp('thinlinc/conf.d/vsm.hconf.epp', {
      # NOTE: it somehow fails with full version like 4.14.0-2408, so lets skip the last bit '-2408'
      formatted_version => regsubst($::thinlinc::version, '(.*)?-(.*)$', '\1')
    })
  }

}
