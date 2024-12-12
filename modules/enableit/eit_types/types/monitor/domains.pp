# Blackbox targets
type Eit_types::Monitor::Domains = Optional[Array[Variant[
  Eit_types::FQDNPort,
  Stdlib::Fqdn,
  Stdlib::HttpUrl
]]]
