type Eit_haproxy::Frontend = Struct[{
  domains         => Array[Eit_types::Domain],
  force_https     => Boolean,
  servers         => Array[Eit_types::IPPort],
  extra_opts      => Optional[String],
}]
