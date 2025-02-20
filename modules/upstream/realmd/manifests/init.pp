# Class: realmd
# ===========================
#
# Full description of class realmd here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class realmd (
  String $realmd_package_name,
  String $realmd_package_ensure,
  Stdlib::Absolutepath $realmd_config_file,
  Hash $realmd_config,
  String $homedir_umask,
  String $adcli_package_name,
  String $adcli_package_ensure,
  String $krb_client_package_name,
  String $krb_client_package_ensure,
  String $sssd_package_name,
  String $sssd_package_ensure,
  String $sssd_service_name,
  String $sssd_service_ensure,
  Stdlib::Absolutepath $sssd_config_file,
  Stdlib::Absolutepath $sssd_config_cache_file,
  Hash $sssd_config,
  Boolean $manage_sssd_config,
  Boolean $manage_sssd_service,
  Boolean $manage_sssd_package,
  String $domain,
  String $netbiosname,
  Variant[String, Undef] $domain_join_user,
  Variant[String, Undef] $domain_join_password,
  Variant[String, Undef] $one_time_password,
  Boolean $krb_ticket_join,
  Variant[Stdlib::Absolutepath, Undef] $krb_keytab,
  Stdlib::Absolutepath $krb_config_file,
  Hash $krb_config,
  Boolean $manage_krb_config,
  Variant[String, Undef] $ou,
  Hash $required_packages,
  Variant[Array, Undef] $extra_join_options,
  Variant[String[1, 15], Undef, Boolean[false]] $computer_name,
) {

  if $krb_ticket_join == false {
    if ($domain_join_user and !$domain_join_password) {
      fail('Cannot set domain_join_user without domain_join_password')
    }
  }
  if ($domain_join_password and !$domain_join_user) {
    fail('Cannot set domain_join_password without domain_join_user')
  }
  if ($one_time_password and $domain_join_user) {
    fail('Cannot do a machine login with one_time_password, when a domain_join_user is set')
  }

  if $manage_sssd_config and empty($sssd_config) {
    fail('The sssd_config parameter cannot be an empty hash when managing the SSSD configuration')
  }

  if $manage_krb_config and empty($krb_config) {
    fail('The krb_config parameter cannot be an empty hash when managing the Kerberos client configuration')
  }

  contain 'realmd::install'
  contain 'realmd::config'
  contain 'realmd::join'
  contain 'realmd::sssd::config'

  Class['realmd::install']
  -> Class['realmd::config']
  ~> Class['realmd::join']
  -> Class['realmd::sssd::config']

  if $manage_sssd_service {
    contain 'realmd::sssd::service'
    Class['realmd::sssd::config'] ~> Class['realmd::sssd::service']
  }

}
