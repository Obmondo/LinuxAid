# Syslog facilities in `C` compatible format
type Simplib::Syslog::CFacility = Variant[
  Integer[0,23],
  Enum[
    'LOG_KERN',
    'LOG_USER',
    'LOG_MAIL',
    'LOG_DAEMON',
    'LOG_AUTH',
    'LOG_SYSLOG',
    'LOG_LPR',
    'LOG_NEWS',
    'LOG_UUCP',
    'LOG_AUTHPRIV',
    'LOG_FTP',
    'LOG_CRON',
    'LOG_LOCAL0',
    'LOG_LOCAL1',
    'LOG_LOCAL2',
    'LOG_LOCAL3',
    'LOG_LOCAL4',
    'LOG_LOCAL5',
    'LOG_LOCAL6',
    'LOG_LOCAL7'
  ]
]
