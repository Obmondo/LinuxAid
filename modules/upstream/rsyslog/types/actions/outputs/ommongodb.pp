# Struct data type for the Rsyslog MongoDB output module's Action options
type Rsyslog::Actions::Outputs::Ommongodb = Struct[{
    uristr              => Optional[String[1]],
    ssl_cert            => Optional[Stdlib::Absolutepath],
    ssl_ca              => Optional[Stdlib::Absolutepath],
    db                  => Optional[String[1]],
    collection          => Optional[String[1]],
    allowed_error_codes => Optional[Array[String[1]]],
    template            => Optional[String[1]],
    server              => Optional[Stdlib::Host],
    serverported        => Optional[Stdlib::Port],
    uid                 => Optional[String[1]],
    pwd                 => Optional[String[1]],
}]
