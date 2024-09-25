# security stuff; certs and more
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
