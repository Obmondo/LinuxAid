# @summary Class for managing system authentication
#
# @param allowed_users Allowed users list of type Eit_types::Common::Allowed_users.
#
# @param manage_pam Boolean to manage PAM configuration. Defaults to false.
#
# @param manage_sssd Boolean to manage SSSD configuration. Defaults to false.
#
# @param manage_nis Boolean to manage NIS configuration. Defaults to false.
#
# @param manage Boolean to control overall management. Defaults to false.
#
# @param allow_managed_users Boolean to allow managed users. Defaults to true.
#
# @param ignore_expired_root_password Boolean to ignore expired root password checks. Defaults to false.
#
# @param purge_ubuntu_user Boolean to purge Ubuntu user. Defaults to false.
#
# @param purge_users Boolean to purge users. Defaults to false.
#
# @param protected_users Array of type Eit_types::User specifying protected users. Defaults to an empty array.
#
class common::system::authentication (
  Eit_types::Common::Allowed_users $allowed_users,
  Boolean                          $manage_pam,
  Boolean                          $manage_sssd,
  Boolean                          $manage_nis,
  Boolean                          $manage_sudo,
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
    if $manage_sudo {
      include common::system::authentication::sudo
    }
    if $purge_ubuntu_user or $purge_users or $ignore_expired_root_password {
      include profile::system::authentication
    }
  }
}
