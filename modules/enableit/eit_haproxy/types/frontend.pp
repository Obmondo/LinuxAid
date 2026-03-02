type Eit_haproxy::Frontend = Struct[{
    domains         => Array[Eit_types::Domain, 1], # Minimum one domain is required, else fail
    force_https     => Boolean,
    servers         => Array[Eit_types::IPPort],
    extra_opts      => Optional[String],
}]
