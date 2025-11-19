# Data type for multiple replication jobs
type Eit_types::Common::Storage::Zfs::Replications = Hash[
  String[1],
  Struct[{
    'enabled' => Optional[Boolean],
    'source'  => Stdlib::Host,
  }]
]
