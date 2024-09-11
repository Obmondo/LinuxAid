# SSSD Profile
class common::system::authentication::sssd (
  Array[Eit_types::Sssd::Service]             $services              = [
    'nss',
    'pam',
    'ssh',
    'sudo',
  ],
  # variable in hiera as it may depend on distribution
  Array[Eit_types::Sssd::Service]             $_available_services   = undef,
  Boolean                                     $enable                = false,
  Boolean                                     $manage                = $common::system::authentication::manage_sssd,
  Eit_types::Sssd::Domains                    $domains               = {},
  Optional[Eit_types::Domain]                 $default_domain_suffix = undef,
  Optional[Eit_types::Sssd::Debug_Level]      $debug_level           = '0x0620',
  Boolean                                     $manage_oddjobd        = true,
  Eit_types::Sssd::Full_name_format           $full_name_format      = '%1$s',
  Optional[Eit_types::Sssd::Override_homedir] $override_homedir      = undef,
  Hash                                        $override_config       = {},
  Optional[Boolean]                           $noop_value            = undef,
  Array                                       $required_packages     = ['realmd', 'samba-common-tools', 'fprintd-pam'],
) {

  if $manage {
    include ::profile::system::authentication::sssd
  }

}
