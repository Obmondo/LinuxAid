# @summary realmd
#
# Installs, configures, and joins a domain using realmd.
# Optionally control the Kerberos client and SSSD configuration files and the SSSD service.
#
# Default values for all parameters are in hiera.
#
# @param realmd_package_name
#   The name of the main Realmd package
# @param realmd_package_ensure
# @param realmd_config_file
#   The absolute path of the Realmd configuration file
# @param realmd_config
#   A hash of configuration options structured in an ini-style format
# @param homedir_umask
#   A string of the umask for the default directory permissions created by mkhomedir with Debian
# @param adcli_package_name
#   The name of the adcli package
# @param adcli_package_ensure
# @param krb_client_package_name
#   The name of the Kerberos client package
# @param krb_client_package_ensure
# @param sssd_package_name
#   The name of the main SSSD package
# @param sssd_package_ensure
# @param sssd_service_name
#   The name of the SSSD service
# @param sssd_service_ensure
# @param sssd_config_file
#   The absolute path of the SSSD configuration file
# @param sssd_config_cache_file
# @param sssd_config
#   A hash of configuration options structured in an ini-style format
# @param manage_sssd_config
#   Enable or disable management of the SSSD configuration file
# @param manage_sssd_service
#   Enable or disable management of the SSSD service
# @param manage_sssd_package
# @param manage_krb5_package
# @param domain
#   The name of the domain to join
# @param netbiosname
#   The computer name used with one-time-password (computer account) join
# @param domain_join_user
#   The account to be used in joining the domain
# @param domain_join_password
#   The password of the account to be used in joining the domain
# @param one_time_password
#   The password of the prepared computer account
# @param krb_ticket_join
#   Enable of disable joining the domain via a Kerberos keytab
# @param krb_keytab
#   The absolute path to the Kerberos keytab file to be used in joining the domain
# @param krb_config_file
#   The absolute path to the Kerberos client configuration file
# @param krb_config
#   A hash of configuration options structured in an ini-style format
# @param manage_krb_config
#   Enable or disable management of the Kerberos client configuration file
# @param ou
#   The computer organizational unit
# @param required_packages
#   A hash of package resources to manage for any auxilliary functionality
# @param extra_join_options
#   Extra arguments passed to realm join command
# @param computer_name
#   The computer name used with password join
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
  Boolean $manage_krb5_package,
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
