# Data type for Sanoid template configuration
type Sanoid::Template = Struct[{
  frequently => Integer[0, 60],
  hourly     => Integer[0, 48],
  daily      => Integer[0, 30],
  monthly    => Integer[0, 12],
  yearly     => Integer[0, 10],
  autosnap   => Boolean,
  autoprune  => Boolean,
}]
