# Data type for Sanoid pool configuration
type Sanoid::Pool = Struct[{
  template  => String[1],
  recursive => Boolean,
}]
