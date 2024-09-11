type Eit_types::Sudoers = Hash[
  String,
  Struct[{
    'priority' => Optional[Integer[1]],
    'content'  => String,
  }]
]
