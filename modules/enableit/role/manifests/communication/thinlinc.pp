
# @summary Class for managing the ThinLinc communication role
#
# @param webadm_password The password for the web administrator.
#
# @param version The version of ThinLinc. Defaults to '4.9.0'.
#
# @param enable A flag to enable the ThinLinc communication role. Defaults to true.
#
# @param ha A flag to enable high availability. Defaults to false.
#
# @param masters A list of master hosts. Defaults to an empty array.
#
# @param agents A list of agent hosts. Defaults to an empty array.
#
# @param agent_hostname The hostname for the agent. Defaults to undef.
#
# @param max_session_per_user The maximum number of sessions allowed per user. Defaults to 1.
#
# @param shadowing_shadow_mode The shadow mode for ThinLinc. Defaults to 'ask'.
#
# @param shadowing_allowed_shadowers A list of users allowed to shadow sessions. Defaults to an empty array.
#
# @param master_hostname The hostname of the master ThinLinc server. Defaults to 'localhost'.
#
# @param loadbalancer_ip The IP address of the load balancer. Defaults to undef.
#
class role::communication::thinlinc (
  Eit_types::Password    $webadm_password,
  String                 $version                     = '4.9.0',
  Boolean                $enable                      = true,
  Boolean                $ha                          = false,
  Array[Stdlib::Host]    $masters                     = [],
  Array[Stdlib::Host]    $agents                      = [],
  Optional[Stdlib::Host] $agent_hostname              = undef,
  Integer[0,default]     $max_session_per_user        = 1,
  ThinLinc::ShadowMode   $shadowing_shadow_mode       = 'ask',
  Array[Eit_types::User] $shadowing_allowed_shadowers = [],
  Stdlib::Host           $master_hostname             = 'localhost',
  Optional[Stdlib::IP::Address] $loadbalancer_ip      = undef,
) inherits ::role::communication {

  confine($enable, $::common::system::selinux::enable, 'selinux must be disabled')

  if $enable {
    contain 'profile::communication::thinlinc'
  }
}
