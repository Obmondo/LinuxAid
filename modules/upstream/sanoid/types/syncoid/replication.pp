# Data type for a single replication job
type Sanoid::Syncoid::Replication = Struct[{
  source      => String[1],
  destination => String[1],
  options     => Optional[Sanoid::Syncoid::Options],
}]
