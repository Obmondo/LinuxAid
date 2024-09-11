# Matches the types of auditd profiles allowed
type Auditd::AuditProfile = Enum[
  'simp',
  'stig',
  'custom'
]
