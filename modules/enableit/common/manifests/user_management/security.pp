# @summary Class for managing security settings including certs, auditd and fail2ban
#
# @param manage Boolean flag to enable or disable security management. Defaults to true.
#
# @groups management manage
#
class common::user_management::security (
  Boolean $manage = true,
) {
  if $manage {
    if lookup('common::user_management::security::auditd::enable', Boolean, undef, false) {
      contain common::user_management::security::auditd
    }
    if lookup('common::user_management::security::fail2ban::enable', Boolean, undef, false) {
      contain common::user_management::security::fail2ban
    }
    contain common::user_management::security::pkexec
    contain common::user_management::security::effective_group
  }
}
