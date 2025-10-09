type Rsyslog::Actions::Outputs::Omhiredis = Struct[{
  server         => Optional[Stdlib::Host],
  serverport     => Optional[Stdlib::Port],
  serverpassword => Optional[String[1]],
  mode           => Optional[Enum['queue', 'publish', 'template']],
  template       => Optional[String[1]],
  key            => Optional[String[1]],
  userpush       => Optional[Enum['on', 'off']]
}]
