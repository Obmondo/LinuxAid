# == Class realmd::join::password
#
# This class is called from realmd for
# joining AD using a username and password.
# The default password for Windows ADS is 
# "the first 15 chars of the hostname in lowercase"
#
class realmd::join::one_time_password {

  $_domain            = $::realmd::domain
  $_netbiosname       = $::realmd::netbiosname
  $_ou                = $::realmd::ou
  $_krb_config_file   = $::realmd::krb_config_file
  $_krb_config        = $::realmd::krb_config
  $_manage_krb_config = $::realmd::manage_krb_config

  $_krb_config_final = deep_merge({'libdefaults' => {'default_realm' => upcase($::domain)}}, $_krb_config)
  if !$::realmd::one_time_password  {
        $_password=$::hostname[0,15]
    }
    else {
        $_password=$::realmd::one_time_password
  }
  $_realm=upcase($::realmd::domain)
  $_fqdn=$::fqdn

  if $_manage_krb_config {
    file { 'krb_configuration':
      ensure  => file,
      path    => $_krb_config_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('realmd/krb5.conf.erb'),
    }
  }

  if $::operatingsystem == 'Ubuntu' and $facts['os']['distro']['codename']  == 'xenial' {
    $_computer_name_arg  = ''
  } else {
      $_computer_name_arg = ["--computer-name=${_netbiosname}"]
  }

  if !empty($_netbiosname) {
    $_check_pricipal = $_netbiosname
    $_domain_args = ["--domain=${_domain}", "--user-principal=host/${_fqdn}@${_realm}",
                    '--login-type=computer', $_computer_name_arg]
  } else {
    $_check_pricipal = $::hostname[0,15]
    $_domain_args = ["--domain=${_domain}", "--user-principal=host/${_fqdn}@${_realm}", '--login-type=computer']
  }

  if $_ou != undef {
      $_ou_args=["--computer-ou='OU=${_ou}'"]
  }
  else {
      $_ou_args=[]
  }

  if $::realmd::one_time_password != undef {
      $_password_args=["--one-time-password='${$::realmd::one_time_password}'"]
  }
  else {
      $_password_args=['--no-password']
  }


  $_args = join(concat( $_domain_args, $_ou_args, $_password_args), ' ')

  exec { 'realm_join_one_time_password':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "adcli join ${_args}",
    unless  => "klist -k /etc/krb5.keytab | grep -i '${_check_pricipal}@${_domain}'",
  }
}
