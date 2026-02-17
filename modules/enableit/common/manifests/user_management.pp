# @summary Class for managing user related configurations
#
# @param authentication Boolean to enable authentication management. Defaults to true.
#
# @param security Boolean to enable security management. Defaults to true.
#
# @param motd Boolean to enable MOTD management. Defaults to true.
#
# @param sshd Boolean to enable SSHD management. Defaults to true.
#
# @groups management authentication, security, motd, sshd
#
class common::user_management (
  Boolean $authentication = true,
  Boolean $security       = true,
  Boolean $motd           = true,
  Boolean $sshd           = true,
) {
  if $authentication {
    contain common::user_management::authentication
  }
  if $security {
    contain common::user_management::security
  }
  if $motd {
    contain common::user_management::motd
  }
  if $sshd {
    contain common::user_management::sshd
  }
}
