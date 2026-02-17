#
class profile::system::authentication (
  Eit_types::Common::Allowed_users $allowed_users                = $::common::user_management::authentication::allowed_users,
  Boolean                          $allow_managed_users          = $::common::user_management::authentication::allow_managed_users,
  Boolean                          $manage_pam                   = $::common::user_management::authentication::manage_pam,
  Boolean                          $ignore_expired_root_password = $::common::user_management::authentication::ignore_expired_root_password,
  Boolean                          $purge_ubuntu_user            = $::common::user_management::authentication::purge_ubuntu_user,
  Boolean                          $purge_users                  = $::common::user_management::authentication::purge_users,
  Array[Eit_types::User]           $protected_users              = $::common::user_management::authentication::protected_users,
) {

  if $ignore_expired_root_password {
    exec { 'reset root password expiry':
      command => '/bin/sh -c "chage -d $(date +%F) root; passwd --lock root"',
      onlyif  => '/bin/sh -c "chage -l root | grep -q \'password must be changed\'"',
    }
  }

  if $purge_users {
    $_purge_unless = $protected_users.map |$u| {
      $u ? {
        Integer => ['uid', '==', String($u)],
        String  => ['name', '==', $u],
      }
    }

    purge { 'user':
      unless => [
        ['uid', '<', '1000' ],
        ['name', '==', ['nobody']],
      ] + $_purge_unless,
    }
  }

  if $purge_ubuntu_user {
    user { 'ubuntu':
      ensure     => absent,
      managehome => false,
    }
  }

}
