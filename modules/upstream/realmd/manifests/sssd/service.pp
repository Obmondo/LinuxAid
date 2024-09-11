# == Class realmd::sssd::service
#
# This class is meant to be called from realmd.
# It ensure the service is running.
#
class realmd::sssd::service {

  $_sssd_service_name = $::realmd::sssd_service_name

  if $realmd::manage_sssd_config {
    service { $_sssd_service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
