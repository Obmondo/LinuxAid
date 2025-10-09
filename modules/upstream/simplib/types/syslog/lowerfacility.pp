# Valid lowercase versions of syslog facilities
type Simplib::Syslog::LowerFacility = Variant[
  Integer[0,23],
  Enum[
    'kern',
    'user',
    'mail',
    'daemon',
    'auth',
    'syslog',
    'lpr',
    'news',
    'uucp',
    'authpriv',
    'ftp',
    'cron',
    'local0',
    'local1',
    'local2',
    'local3',
    'local4',
    'local5',
    'local6',
    'local7'
  ]
]
