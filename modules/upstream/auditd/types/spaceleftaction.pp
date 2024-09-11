# Matches spaceleftaction for auditd.conf
type Auditd::SpaceLeftAction = Enum[
  'IGNORE','SYSLOG','ROTATE','EMAIL','EXEC','SUSPEND','SINGLE','HALT',
  'ignore','syslog','rotate','email','exec','suspend','single','halt'
]
