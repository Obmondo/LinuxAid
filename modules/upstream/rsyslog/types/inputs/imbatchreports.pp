# Data type for Rsyslog Input module parameters for batch report inputs.
type Rsyslog::Inputs::Imbatchreports = Struct[{
    reports           => String[1],
    tag               => String[1],
    facility          => Optional[Stdlib::Syslogfacility],
    severity          => Optional[Rsyslog::Syslog::Severity],
    deduplicatespaces => Optional[Enum['on', 'off']],
    delete            => Optional[String[1]],
    rename            => Optional[String[1]],
    programkey        => Optional[String[1]],
    timestampkey      => Optional[String[1]],
}]
