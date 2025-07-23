type Rsyslog::Actions::Outputs::Omhttpfs = Struct[{
    host      => Optional[Stdlib::Host],
    port      => Optional[Stdlib::Port],
    user      => Optional[String[1]],
    https     => Optional[Enum['on', 'off']],
    file      => String[1],
    isdynfile => Optional[Enum['on', 'off']],
    template  => Optional[String[1]]
}]
