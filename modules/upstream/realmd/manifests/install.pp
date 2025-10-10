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

  package { $::realmd::krb_client_package_name:
    ensure => $::realmd::krb_client_package_ensure,
  }

  if $realmd::manage_sssd_package {
    package { $::realmd::sssd_package_name:
      ensure => $::realmd::sssd_package_ensure,
    }
  }

  case $facts['os']['name'] {
    'Ubuntu': {
      include apt

      Exec['apt_update']
      -> Package[[
        $::realmd::realmd_package_name,
        $::realmd::adcli_package_name,
        $::realmd::adcli_package_name,
        $::realmd::krb_client_package_name,
      ]]

      if $realmd::manage_sssd_package {
        Exec['apt_update'] -> Package[$::realmd::sssd_package_name]
      }

      $::realmd::required_packages.each | String $package, Hash $content | {
        Exec['apt_update']
        -> package { $package:
          ensure  => $content['ensure'],
        }
      }
    }
    default: {
      ensure_packages($::realmd::required_packages)
    }
  }

}
