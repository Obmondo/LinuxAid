type Rsyslog::Actions::Outputs::Omamqp1 = Struct[{
    host           => String[1],
    target         => String[1],
    username       => Optional[String[1]],
    password       => Optional[String[1]],
    template       => Optional[String[1]],
    idletimeout    => Optional[Integer],
    reconnectdelay => Optional[Integer],
    maxretries     => Optional[Integer],
    disablesasl    => Optional[Integer],
}]
