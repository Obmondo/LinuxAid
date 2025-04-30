# Kerberos integration
class common::system::authentication::kerberos (
  Boolean                       $manage         = $common::system::authentication::manage_sssd,
  Boolean                       $enable         = false,
  Optional[String]              $base_dn        = undef,
  Optional[String]              $ou             = undef,
  Optional[Eit_types::Domain]   $default_realm  = undef,
  Optional[Hash]                $appdefaults    = undef,
  Boolean                       $join           = false,
  Optional[Eit_types::Password] $join_password  = undef,
  Optional[Eit_types::User]     $join_user      = undef,
  Boolean                       $install_client = false,
  Boolean                       $ldaps          = false,
  Optional[Boolean]             $noop_value     = undef,
  Optional[Stdlib::Unixpath]    $cacert_path    = undef,

  Optional[Eit_types::Common::System::Authentication::Kerberos::Realms] $realms = undef,
) {

  confine($join, !($join_user and $join_password),
          '`join_user` and `join_password` must be provided for join to work')

  confine($enable, !($default_realm and $realms),
          '`default_realm` and `realms` must be provided when kerberos authentication is enabled')

  if $manage {
    include ::profile::system::authentication::kerberos
  }
}
