# Syslog severity data type
type Rsyslog::Syslog::Severity = Variant[
  Enum[
    'emerg',
    'alert',
    'crit',
    'err',
    'warning',
    'notice',
    'info',
    'debug',
  ],
  Integer[0, 7],
]
