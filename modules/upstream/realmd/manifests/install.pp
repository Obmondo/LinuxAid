# == Class realmd::install
#
# This class is called from realmd for install.
#
class realmd::install {
  package { $realmd::realmd_package_name:
    ensure => $realmd::realmd_package_ensure,
  }

  package { $realmd::adcli_package_name:
    ensure => $realmd::adcli_package_ensure,
  }

  if $realmd::manage_krb5_package {
    package { $realmd::krb_client_package_name:
      ensure => $realmd::krb_client_package_ensure,
    }
  }

  if $realmd::manage_sssd_package {
    package { $realmd::sssd_package_name:
      ensure => $realmd::sssd_package_ensure,
    }
  }

  stdlib::ensure_packages($realmd::required_packages)
}
