# thinlinc
#
# https://www.cendio.com/resources/docs/tag/ch06s02.html
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

  confine($enable,
          $::common::system::selinux::enable,
          'selinux must be disabled')

  if $enable {
    contain 'profile::communication::thinlinc'
  }
}
