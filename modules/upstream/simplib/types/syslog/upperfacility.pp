# Valid uppercase bounds for syslog facilities
type Simplib::Syslog::UpperFacility = Variant[
  Integer[0,23],
  Enum[
    'KERN',
    'USER',
    'MAIL',
    'DAEMON',
    'AUTH',
    'SYSLOG',
    'LPR',
    'NEWS',
    'UUCP',
    'AUTHPRIV',
    'FTP',
    'CRON',
    'LOCAL0',
    'LOCAL1',
    'LOCAL2',
    'LOCAL3',
    'LOCAL4',
    'LOCAL5',
    'LOCAL6',
    'LOCAL7'
  ]
]
