# Valid $special parameter to Cron::Job.
type Cron::Special = Optional[
  Enum['annually',
    'daily',
    'hourly',
    'midnight',
    'monthly',
    'reboot',
    'weekly',
    'yearly',
  ]
]
