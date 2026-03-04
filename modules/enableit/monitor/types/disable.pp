type Monitor::Disable = Variant[
  Undef,
  Struct[{
    crons => Monitor::Crontab
  }]
]
