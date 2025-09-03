# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thinlinc::vsmserver
class thinlinc::vsmserver (
  String                         $admin_email              = $::thinlinc::vsmserver_admin_email,
  Array[Stdlib::Host]            $terminal_servers         = $::thinlinc::vsmserver_terminal_servers,
  Integer[0,default]             $ram_per_user_mb          = $::thinlinc::vsmserver_ram_per_user_mb,
  Integer[0,default]             $bogomips_per_user        = $::thinlinc::vsmserver_bogomips_per_user,
  Integer[0,default]             $existing_users_weight    = $::thinlinc::vsmserver_existing_users_weight,
  Integer[0,default]             $load_update_cycle        = $::thinlinc::vsmserver_load_update_cycle,
  Integer[0,default]             $max_session_per_user     = $::thinlinc::vsmserver_max_session_per_user,
  Optional[Array[Stdlib::Host]]  $allowed_clients          = $::thinlinc::vsmserver_allowed_clients,
  Optional[Array[String]]        $allowed_groups           = $::thinlinc::vsmserver_allowed_groups,
  Boolean                        $unbind_ports_at_login    = $::thinlinc::vsmserver_unbind_ports_at_login,
  Optional[Array[String]]        $explicit_agent_selection = $::thinlinc::vsmserver_explicit_agent_selection,
  Stdlib::Port                   $listen_port              = $::thinlinc::vsmserver_listen_port,

  Optional[Boolean]              $enable_ha                = $::thinlinc::vsmserver_enable_ha,
  Optional[Array[Stdlib::Host]]  $ha_nodes                 = $::thinlinc::vsmserver_ha_nodes,

  Optional[Array[Stdlib::Host]]  $subcluster_agents        = $::thinlinc::vsmserver_subcluster_agents,

  Boolean                        $log_to_file              = $::thinlinc::vsmserver_log_to_file,
  Stdlib::Absolutepath           $log_dir                  = $::thinlinc::vsmserver_log_dir,
  Boolean                        $log_to_syslog            = $::thinlinc::vsmserver_log_to_syslog,
  String                         $syslog_facility          = $::thinlinc::vsmserver_syslog_facility,
  Stdlib::Absolutepath           $syslog_socket            = $::thinlinc::vsmserver_syslog_socket,
  Optional[Stdlib::Host]         $syslog_host              = $::thinlinc::vsmserver_syslog_host,
  ThinLinc::LogLevel             $default_log_level        = $thinlinc::default_log_level,
  ThinLinc::LogLevel             $extcmd_log_level         = $::thinlinc::vsmserver_extcmd_log_level,
  ThinLinc::LogLevel             $session_log_level        = $::thinlinc::vsmserver_session_log_level,
  ThinLinc::LogLevel             $shadow_log_level         = $::thinlinc::vsmserver_shadow_log_level,
  ThinLinc::LogLevel             $loadinfo_log_level       = $::thinlinc::vsmserver_loadinfo_log_level,
  ThinLinc::LogLevel             $license_log_level        = $::thinlinc::vsmserver_license_log_level,
  ThinLinc::LogLevel             $xmlrpc_log_level         = $::thinlinc::vsmserver_xmlrpc_log_level,
  ThinLinc::LogLevel             $ha_log_level             = $::thinlinc::vsmserver_ha_log_level,
  Optional[Stdlib::IP::Address]  $loadbalancer_ip          = $::thinlinc::vsmserver_loadbalancer_ip,
) inherits ::thinlinc {

  confine($enable_ha, $ha_nodes.size_ <= 1, 'Enabling HA requires 2 or more nodes')

  thinlinc::ensure_log_dir($log_dir)

  $vsmserver_config_file = "${thinlinc::install_dir}/etc/conf.d/vsmserver.hconf"
  $cluster_config_file = "${thinlinc::install_dir}/etc/conf.d/cluster.hconf"

  file { $vsmserver_config_file:
    ensure  => 'file',
    content => epp('thinlinc/conf.d/vsmserver.hconf.epp'),
    notify  => Service['vsmserver'],
  }

  file { $cluster_config_file:
    ensure  => 'file',
    content => epp('thinlinc/conf.d/cluster.hconf.epp'),
    notify  => Service['vsmserver'],
  }

  if $log_to_file {
    logrotate::rule { 'thinlinc-vsm-server':
      path         => "${log_dir}/vsmserver.log",
      copytruncate => true,
    }
  }

  if $enable_ha {
    firewall_multi { '200 allow vsmserver from other master servers':
      jump   => 'accept',
      dport  => $listen_port,
      proto  => 'tcp',
      source => if $ha_nodes.count {
        $ha_nodes
      }
    }

    network_config { 'eth0':
      ensure    => 'present',
      ipaddress => $loadbalancer_ip,
    }
  }
}
