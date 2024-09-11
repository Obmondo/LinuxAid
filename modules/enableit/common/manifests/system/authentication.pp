# Authentication class
class common::system::authentication (
  Eit_types::Common::Allowed_users $allowed_users,
  Boolean                          $manage_pam,
  Boolean                          $manage_sssd,
  Boolean                          $manage_nis,
  Boolean                          $manage,
  Boolean                          $allow_managed_users          = true,
  Boolean                          $ignore_expired_root_password = false,
  Boolean                          $purge_ubuntu_user            = false,
  Boolean                          $purge_users                  = false,
  Array[Eit_types::User]           $protected_users              = [],
) {

  if $manage {
    if $manage_sssd {

      confine($manage_sssd, !$manage_pam, 'if sssd is enabled, pam can\'t be set to false, please enable it')

      include common::system::authentication::kerberos
      include common::system::authentication::pam
      include common::system::authentication::sssd
    }

    if $manage_pam {
      include common::system::authentication::pam
    }

    if $manage_nis {
      include common::system::authentication::nis
    }

    if $purge_ubuntu_user or $purge_users or $ignore_expired_root_password {
      include profile::system::authentication
    }
  }

  # NOTE: need this for our own sudo setup for obmondo-admin
  include common::system::authentication::sudo
}
