# @summary Class for managing SSSD profile for system authentication
#
# @param services Array of SSSD services to enable. Defaults to ['nss', 'pam', 'ssh', 'sudo'].
#
# @param _available_services Available services for SSSD. Defaults to undef.
#
# @param enable Boolean to enable or disable SSSD. Defaults to false.
#
# @param domains SSSD domain configurations. Defaults to empty hash.
#
# @param default_domain_suffix Default domain suffix. Defaults to undef.
#
# @param manage_oddjobd Boolean to manage oddjobd service. Defaults to true.
#
# @param override_homedir Override for home directory. Defaults to undef.
#
# @param override_config Additional override configurations for SSSD. Defaults to empty hash.
#
# @param noop_value Optional boolean for no-op mode. Defaults to undef.
#
# @param required_packages List of required packages for SSSD. Defaults to ['realmd', 'samba-common-tools', 'fprintd-pam'].
class common::user_management::authentication::sssd (
  Array[Eit_types::Sssd::Service] $services = [
    'nss',
    'pam',
    'ssh',
    'sudo',
    'pac',
  ],
  Array[Eit_types::Sssd::Service]             $_available_services   = undef,
  Boolean                                     $enable                = false,
  Eit_types::Sssd::Domains                    $domains               = {},
  Optional[Eit_types::Domain]                 $default_domain_suffix = undef,
  Boolean                                     $manage_oddjobd        = true,
  Optional[Eit_types::Sssd::Override_homedir] $override_homedir      = undef,
  Hash                                        $override_config       = {},
  Eit_types::Noop_Value                       $noop_value            = undef,
  Array                                       $required_packages     = ['realmd', 'samba-common-tools', 'fprintd-pam'],
) {
  if $common::user_management::authentication::manage_sssd {
    include ::profile::system::authentication::sssd
  }
}
