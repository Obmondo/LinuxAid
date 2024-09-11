# Syslog severities in `C` compatible format
type Simplib::Syslog::CSeverity = Variant[
  Integer[0,7],
  Enum[
    'LOG_EMERG',
    'LOG_ALERT',
    'LOG_CRIT',
    'LOG_ERR',
    'LOG_WARNING',
    'LOG_NOTICE',
    'LOG_INFO',
    'LOG_DEBUG'
  ]
]
