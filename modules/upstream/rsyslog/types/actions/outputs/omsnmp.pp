# Struct data type for the Rsyslog SNMP module's Action options
type Rsyslog::Actions::Outputs::Omsnmp = Struct[{
    server => Stdlib::Host,
    port   => Optional[Stdlib::Port],
    transport => Optional[String[1]],
    version   => Optional[Integer[0,1]],
    community => Optional[String[1]],
    trapoid   => Optional[String[1]],
    messageoid => Optional[String[1]],
    enterpriseoid => Optional[String[1]],
    specifictype  => Optional[Integer],
    traptype      => Optional[Integer[0,6]],
}]
