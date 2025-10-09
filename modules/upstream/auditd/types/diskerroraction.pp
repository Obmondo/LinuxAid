# Matches disk error actions in auditd.conf
type Auditd::DiskErrorAction = Enum[
  'IGNORE','SYSLOG','EXEC','SUSPEND','SINGLE','HALT',
  'ignore','syslog','exec','suspend','single','halt'
]
