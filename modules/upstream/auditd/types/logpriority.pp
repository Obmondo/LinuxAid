# Matches log priorities that can be used in syslog.conf plugin
type Auditd::LogPriority = Enum['LOG_DEBUG', 'LOG_INFO', 'LOG_NOTICE', 'LOG_WARNING', 'LOG_ERR', 'LOG_CRIT', 'LOG_ALERT', 'LOG_EMERG','LOG_AUTHPRIV']
