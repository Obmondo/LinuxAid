# Matches actions to take when disk is full (see auditd.conf)
type Auditd::DiskFullAction = Enum[
  'IGNORE','SYSLOG','ROTATE','EXEC','SUSPEND','SINGLE','HALT',
  'ignore','syslog','rotate','exec','suspend','single','halt'
]
