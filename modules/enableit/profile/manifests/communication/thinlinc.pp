# thinlinc
#
# https://www.cendio.com/resources/docs/tag/ch06s02.html
class profile::communication::thinlinc (
  Boolean                 $ha                          = $role::communication::thinlinc::ha,
  String                  $version                     = $role::communication::thinlinc::version,
  Array[Stdlib::Host]     $masters                     = $role::communication::thinlinc::masters,
  Optional[Stdlib::Host]  $agent_hostname              = $role::communication::thinlinc::agent_hostname,
  Eit_types::Password     $webadm_password             = $role::communication::thinlinc::webadm_password,
  Boolean                 $enable                      = $role::communication::thinlinc::enable,
  ThinLinc::ShadowMode    $shadowing_shadow_mode       = $role::communication::thinlinc::shadowing_shadow_mode,
  Optional[Array[String]] $shadowing_allowed_shadowers = $role::communication::thinlinc::shadowing_allowed_shadowers,
  Integer[0,default]      $max_session_per_user        = $role::communication::thinlinc::max_session_per_user,
  Array[Stdlib::Host]     $agents                      = $role::communication::thinlinc::agents,
  Stdlib::Host            $master_hostname             = $role::communication::thinlinc::master_hostname,
  Optional[Stdlib::IP::Address] $loadbalancer_ip       = $role::communication::thinlinc::loadbalancer_ip,
) inherits ::profile {

  confine($ha, !$loadbalancer_ip,
          'Needs to have loadbalancer IP set for ThinLinc HA to work')

  class { '::thinlinc':
    tlwebadm_password              => $webadm_password.pw_hash('sha-512', fqdn_rand_string(20)),
    shadowing_shadow_mode          => $shadowing_shadow_mode,
    shadowing_allowed_shadowers    => $shadowing_allowed_shadowers,
    vsmserver_ha_nodes             => $masters,
    vsmserver_max_session_per_user => $max_session_per_user,
    vsmagent_allowed_clients       => $masters,
    vsmagent_agent_hostname        => $agent_hostname,
    vsmserver_subcluster_agents    => $agents,
    vsmagent_master_hostname       => $master_hostname,
    vsmserver_enable_ha            => $ha,
    vsmagent_enable_ha             => $ha,
    version                        => $version,
    vsmserver_loadbalancer_ip      => $loadbalancer_ip,
  }
}
