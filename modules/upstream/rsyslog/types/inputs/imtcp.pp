# Data type for Rsyslog TCP input module
type Rsyslog::Inputs::Imtcp = Struct[{
  port                       => Stdlib::Port,
  address                    => Optional[Stdlib::IP::Address::V4],
  name                       => Optional[String[1]],
  ruleset                    => Optional[String[1]],
  supportoctetcountedframing => Optional[Enum['on', 'off']],
  'ratelimit.interval'       => Optional[Integer],
  'ratelimit.burst'          => Optional[Integer],
  listenportfilename         => Optional[String[1]],
}]
