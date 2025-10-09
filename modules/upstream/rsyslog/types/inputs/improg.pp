# Data type for Rsyslog Input module input parameters for Program input
type Rsyslog::Inputs::Improg = Struct[{
  binary           => String[1],
  tag              => String[1],
  facility         => Optional[Stdlib::Syslogfacility],
  severity         => Optional[Rsyslog::Syslog::Severity],
  confirmmessages  => Optional[Enum['on', 'off']],
  signalonclose    => Optional[Enum['on', 'off']],
  closetimeout     => Optional[Integer],
  killunresponsive => Optional[Enum['on', 'off']],
}]
