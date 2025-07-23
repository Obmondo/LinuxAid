# Data type for Rsyslog UDP input module
type Rsyslog::Inputs::Imudp = Struct[{
    address              => Optional[Stdlib::Host],
    port                 => Stdlib::Port,
    ipfreebind           => Optional[Integer[0,2]],
    device               => Optional[String[1]],
    ruleset              => Optional[String[1]],
    'ratelimit.interval' => Optional[Integer],
    'ratelimit.burst'    => Optional[Integer],
    name                 => Optional[String[1]],
    'name.appendport'    => Optional[Enum['on', 'off']],
    defaulttz            => Optional[String[1]],
    rcvbufsize           => Optional[Variant[Integer, String[1]]],
}]
