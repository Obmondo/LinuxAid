type Eit_haproxy::Listen = Hash[
  String,
  Struct[{
    binds   => Array[Eit_types::IPPort],
    servers => Array[Eit_types::IPPort],
  }]
]
