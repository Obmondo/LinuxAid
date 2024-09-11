# == Class realmd::install
#
# This class is called from realmd for install.
#
class realmd::install {

  package { $::realmd::realmd_package_name:
    ensure => $::realmd::realmd_package_ensure,
  }

  package { $::realmd::adcli_package_name:
    ensure => $::realmd::adcli_package_ensure,
  }

  # NOTE: the krb5-workstation is already declared in
  # mit_krb5 module, but this is a quickest solution for now.
  #package { $::realmd::krb_client_package_name:
  #  ensure => $::realmd::krb_client_package_ensure,
  #}

  package { $::realmd::sssd_package_name:
    ensure => $::realmd::sssd_package_ensure,
  }

  ensure_packages($::realmd::required_packages)

}
