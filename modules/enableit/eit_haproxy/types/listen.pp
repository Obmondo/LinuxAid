type Eit_haproxy::Listen = Hash[
  String,
  Struct[{
    binds         => Array[Eit_types::IPPort],
    bind_options => Optional[Array],
    servers       => Array[Eit_types::IPPort],
  }]
]
