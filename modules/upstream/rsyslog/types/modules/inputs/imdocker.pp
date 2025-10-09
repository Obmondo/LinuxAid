# Data type for Rsyslog module parameters for imdocker
type Rsyslog::Modules::Inputs::Imdocker = Struct[{
  dockerapiunixsockaddr    => Optional[Stdlib::Absolutepath],
  apiversionstr            => Optional[Pattern[/^v([0-9]+)\.([0-9]+)/]],
  pollinginterval          => Optional[Integer],
  listcontaineroptions     => Optional[String[1]],
  getcontainerlogoptions   => Optional[String[1]],
  retrievenewlogsfromstart => Optional[Integer[0,1]],
  defaultfacility          => Optional[Stdlib::Syslogfacility],
  defaultseverity          => Optional[Rsyslog::Syslog::Severity],
  escapelf                 => Optional[Enum['on', 'off']],
}]
