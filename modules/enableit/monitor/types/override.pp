# Override threshold or disable alert
type Monitor::Override = Variant[
  Undef,
  Struct[{
    crons  => Monitor::Crontab,
    expr   => Variant[Integer[0],Float[0]],
    labels => Optional[Hash],
  }]
]
