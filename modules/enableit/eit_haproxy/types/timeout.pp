# Haproxy Timeouts

type Eit_haproxy::Timeout = Struct[{
  client          => Optional[String],
  connect         => Optional[String],
  server          => Optional[String],
  queue           => Optional[String],
  tunnel          => Optional[String],
  check           => Optional[String],
  http-request    => Optional[String],
  http-keep-alive => Optional[String],
  http-connection => Optional[String],
  tarpit          => Optional[String],
}]
