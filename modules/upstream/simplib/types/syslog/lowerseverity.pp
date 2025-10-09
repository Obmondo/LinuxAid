# Valid lowercase versions of syslog severities
type Simplib::Syslog::LowerSeverity = Variant[
  Integer[0,7],
  Enum[
    'emerg',
    'alert',
    'crit',
    'err',
    'warning',
    'notice',
    'info',
    'debug'
  ]
]
