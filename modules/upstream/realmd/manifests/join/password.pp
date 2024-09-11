# == Class realmd::join::password
#
# This class is called from realmd for
# joining AD using a username and password.
#
class realmd::join::password {

  $_domain             = $::realmd::domain
  $_user               = $::realmd::domain_join_user
  $_password           = $::realmd::domain_join_password
  $_ou                 = $::realmd::ou
  $_extra_join_options = $::realmd::extra_join_options

  # FIXME: The hostname length seems to be limited to 15 chars, but doing it
  # this way seems like a surpremely bad way to go about it, as
  # `dkcphsomelonghostname01` and `dkcphsomelonghostname02` would both result in
  # `dkcphsomelongho`.
  $_computer_name = pick($::realmd::computer_name, $facts['hostname'][0,15])

  $_realm_args = [
    $_domain,
    '--unattended',
    "--user=${_user}",
    if $_ou {
      "--computer-ou='${_ou}'"
    },
    unless $::operatingsystem == 'Ubuntu' {
      "--computer-name=${_computer_name}"
    },
  ].delete_undef_values

  ($_realm_args + $_extra_join_options).join(' ').strip

  # NOTE: somehow realmd is giving us a hard time, so lets stick to plain adcli, which works on el6 and el7 (realmd is only on el7)
  # MR #1369
  # For password with special character need to be escaped while encrypting it 
  # eg:- for password #HONDA'CIty  we should encrypt that with \#HONDA\'CIty 
  # Command:-  eyaml encrypt -s "\#HONDA\'CIty"  --pkcs7-public-key="./var/public_key.pkcs7.pem 
  $_command = "echo -n ${_password} | adcli join --login-user=${_user} --domain=${_domain} --domain-ou '${_ou}' --stdin-password"

  file { '/usr/libexec/realm_join_with_password':
    ensure => absent,
  }

  exec { 'realm_join_with_password':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => $_command,
    unless  => "which klist; klist -k /etc/krb5.keytab | grep -i '${_computer_name}@${_domain}'",
    require => Package[
      $::realmd::krb_client_package_name,
      'adcli',
    ],
  }
}
