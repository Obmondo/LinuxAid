# Struct data type for the Rsyslog RELP module's Action options
type Rsyslog::Actions::Outputs::Omrelp = Struct[{
    target               => Variant[Stdlib::Fqdn, Stdlib::IP::Address],
    port                 => Optional[Stdlib::Port],
    template             => Optional[String[1]],
    timeout              => Optional[Integer],
    'conn.timeout'       => Optional[Integer],
    rebindinterval       => Optional[Integer],
    windowsize           => Optional[Integer],
    tls                  => Optional[Enum['on', 'off']],
    'tls.compression'    => Optional[Enum['on', 'off']],
    'tls.permittedpeer'  => Optional[Array[String[1]]],
    'tls.automode'       => Optional[Enum['fingerprint', 'name']],
    'tls.cacert'         => Optional[Stdlib::Absolutepath],
    'tls.mycert'         => Optional[Stdlib::Absolutepath],
    'tls.myprivkey'      => Optional[Stdlib::Absolutepath],
    'tls.prioritystring' => Optional[String[1]],
    localclientip        => Optional[Stdlib::IP::Address],
}]
