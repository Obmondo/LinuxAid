# @summary Class for managing security settings including certs and auditd
#
# @param manage Boolean flag to enable or disable security management. Defaults to true.
#
class common::security (
  Boolean $manage = true,
) {
  if $manage {
    if lookup('common::security::auditd::enable', Boolean, undef, false) {
      contain common::security::auditd
    }
    contain common::security::pkexec
    contain common::security::effective_group
  }
}
