# Microsoft SCOM
class common::monitoring::scom (
  Boolean                       $enable             = false,
  Optional[Array[Stdlib::Host]] $scom_masters       = undef,
  Boolean                       $install_sudo_rules = true,
  Eit_types::User               $scom_user          = 'svclinuxmon',
  Boolean                       $noop_value         = undef,
) {

  if $enable {
    include profile::monitoring::scom
  }
}
