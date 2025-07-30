# @summary Class for managing Kerberos integration
#
# @param manage Whether to manage the Kerberos configuration. Defaults to the value of $common::system::authentication::manage_sssd.
#
# @param enable Enable or disable Kerberos. Defaults to false.
#
# @param base_dn The base distinguished name for Kerberos. Defaults to undef.
#
# @param ou The organizational unit. Defaults to undef.
#
# @param default_realm The default Kerberos realm. Defaults to undef.
#
# @param appdefaults Hash of application defaults for Kerberos. Defaults to undef.
#
# @param join Whether to join the Kerberos realm. Defaults to false.
#
# @param join_password Password used for joining. Defaults to undef.
#
# @param join_user User used for joining. Defaults to undef.
#
# @param install_client Whether to install the Kerberos client. Defaults to false.
#
# @param ldaps Whether to use LDAP over SSL. Defaults to false.
#
# @param noop_value Optional value for noop configuration. Defaults to undef.
#
# @param cacert_path Path to CA certificate. Defaults to undef.
#
# @param realms Hash specifying the Kerberos realms. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class common::system::authentication::kerberos (
  Boolean                       $manage         = $common::system::authentication::manage_sssd,
  Boolean                       $enable         = false,
  Optional[String]              $base_dn        = undef,
  Optional[String]              $ou             = undef,
  Optional[Eit_types::Domain]   $default_realm  = undef,
  Optional                $appdefaults    = undef,
  Boolean                       $join           = false,
  Optional[Eit_types::Password] $join_password  = undef,
  Optional[Eit_types::User]     $join_user      = undef,
  Boolean                       $install_client = false,
  Boolean                       $ldaps          = false,
  Optional[Boolean]             $noop_value     = undef,
  Optional[Stdlib::Unixpath]    $cacert_path    = undef,
  Optional[Eit_types::Common::System::Authentication::Kerberos::Realms] $realms = undef,
  Eit_types::Encrypt::Params    $encrypt_params = ['join_password'],
) {
  confine($join, !($join_user and $join_password),
          '`join_user` and `join_password` must be provided for join to work')
  confine($enable, !($default_realm and $realms),
          '`default_realm` and `realms` must be provided when kerberos authentication is enabled')
  if $manage {
    include ::profile::system::authentication::kerberos
  }
}
