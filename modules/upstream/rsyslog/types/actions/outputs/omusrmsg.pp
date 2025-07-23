# Struct data type for the Rsyslog User MSG module's Action Parameters.
type Rsyslog::Actions::Outputs::Omusrmsg = Struct[{
    users    => String[1],
    template => Optional[String[1]],
}]
