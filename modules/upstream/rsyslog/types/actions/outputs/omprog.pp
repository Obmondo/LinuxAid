# Struct data type for the Rsyslog Program module's Action options
type Rsyslog::Actions::Outputs::Omprog = Struct[{
  template              => Optional[String[1]],
  binary                => Stdlib::Absolutepath,
  confirmmessages       => Optional[Enum['on', 'off']],
  confirmtimeout        => Optional[Integer],
  reportfailures        => Optional[Enum['on', 'off']],
  usetransactions       => Optional[Enum['on', 'off']],
  begintransactionmark  => Optional[String[1]],
  committransactionmark => Optional[String[1]],
  output                => Optional[Stdlib::Absolutepath],
  filecreatemode        => Optional[Stdlib::Filemode],
  'hup.signal'          => Optional[Enum['HUP', 'USR1', 'USR2', 'INT', 'TERM']],
  signalonclose         => Optional[Enum['on', 'off']],
  closetimeout          => Optional[Integer],
  killunresponsive      => Optional[Enum['on', 'off']],
  forcesingleinstance   => Optional[Enum['on', 'off']],
}]
