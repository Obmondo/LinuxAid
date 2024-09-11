# Disable alert during cron timespan
type Monitor::Disable = Variant[
  Undef,
  Struct[{
    crons => Monitor::Crontab
  }]
]
