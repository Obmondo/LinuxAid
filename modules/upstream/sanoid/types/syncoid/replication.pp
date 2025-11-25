# Data type for a single replication job
type Sanoid::Syncoid::Replication = Struct[{
  source  => String[1],
  enabled => Optional[Boolean],
  options => Optional[Sanoid::Syncoid::Options],
}]
