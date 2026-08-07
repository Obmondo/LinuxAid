# @summary Class for managing user related configurations
#
class common::user_management {
  contain common::user_management::authentication
  contain common::user_management::security
  contain common::user_management::motd
  contain common::user_management::sshd

  unless lookup('common::user_management::jumphost::configs', Hash, undef, {}).empty {
    contain common::user_management::jumphosts
  }
}
