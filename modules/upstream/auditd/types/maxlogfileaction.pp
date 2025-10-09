# Matches available matches for maxlogfileaction in auditd.conf
type Auditd::MaxLogFileAction = Enum[
  'IGNORE','SYSLOG','SUSPEND','ROTATE','KEEP_LOGS',
  'ignore','syslog','suspend','rotate','keep_logs'
]
