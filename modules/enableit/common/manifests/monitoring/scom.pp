# @summary Class for managing Microsoft SCOM monitoring configuration
#
# @param enable Whether to enable SCOM monitoring. Defaults to false.
#
# @param scom_masters List of SCOM master hosts. Defaults to undef.
#
# @param install_sudo_rules Whether to install sudo rules for SCOM. Defaults to true.
#
# @param scom_user The user for SCOM operations. Defaults to 'svclinuxmon'.
#
# @param noop_value The noop value for testing purposes. Defaults to undef.
#
class common::monitoring::scom (
  Boolean                       $enable             = false,
  Optional[Array[Stdlib::Host]] $scom_masters       = undef,
  Boolean                       $install_sudo_rules = true,
  Eit_types::User               $scom_user          = 'svclinuxmon',
  Eit_types::Noop_Value         $noop_value         = undef,
) {
  if $enable {
    include profile::monitoring::scom
  }
}
