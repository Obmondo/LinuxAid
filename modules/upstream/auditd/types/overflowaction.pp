# Matches overflow_action settings in auditd.conf or audisp.conf
type Auditd::OverflowAction = Enum['IGNORE','SYSLOG','SUSPEND','SINGLE','HALT','ignore','syslog','suspend','single','halt']
