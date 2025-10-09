# Rsyslog imjournal Module parameter data type
type Rsyslog::Modules::Inputs::Imjournal = Struct[{
  persiststateinterval    => Optional[Integer],
  statefile               => Optional[Stdlib::Absolutepath],
  'ratelimit.interval'    => Optional[Integer],
  'ratelimit.burst'       => Optional[Integer],
  ignorepreviousmessage   => Optional[Enum['on', 'off']],
  defaultseverity         => Optional[Rsyslog::Syslog::Severity],
  defaultfacility         => Optional[Stdlib::Syslogfacility],
  usepidfromsystem        => Optional[Enum['on', 'off']],
  usepid                  => Optional[Enum['syslog', 'system', 'both']],
  ignorenonvalidstatefile => Optional[Enum['on', 'off']],
  workaroundjournalbug    => Optional[Enum['on', 'off']],
}]
