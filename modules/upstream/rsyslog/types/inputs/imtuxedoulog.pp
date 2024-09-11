# Data for Rsyslog Input Tuxedo ULOG module
type Rsyslog::Inputs::Imtuxedoulog = Struct[{
  ulogbase             => Stdlib::Absolutepath,
  tag                  => String[1],
  facility             => Optional[Stdlib::Syslogfacility],
  severity             => Optional[Rsyslog::Syslog::Severity],
  persiststateinterval => Optional[Integer],
  maxlinesatonce       => Optional[Integer],
  maxsubmitatonce      => Optional[Integer],
}]
