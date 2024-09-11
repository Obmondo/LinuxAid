# Valid uppercase versions of syslog severities
type Simplib::Syslog::UpperSeverity = Variant[
  Integer[0,7],
  Enum[
    'EMERG',
    'ALERT',
    'CRIT',
    'ERR',
    'WARNING',
    'NOTICE',
    'INFO',
    'DEBUG'
  ]
]
