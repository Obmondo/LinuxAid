#
type Eit_types::MountLuks = Struct[
  {
  path             => String[1],
  target           => String[1],
  passwdsource     => String[1],
  passwdsourcetype => Enum[httpstore1,textfile],
  }
]
