# Matches the types of auditd profiles allowed
type Auditd::AuditProfile = Enum[
  'built_in',
  'simp',
  'stig',
  'custom'
]
