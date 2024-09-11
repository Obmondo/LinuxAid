type Eit_types::System::Ulimit = Struct[{
  'resource' => Eit_types::System::Ulimit::Resource,
  'domain'   => Variant[
    Enum['*'],
    Eit_types::UserName,
  ],
  'type'     => Array[Enum['hard', 'soft'], 1, 2],
  'value'    => Variant[Enum['unlimited'], Integer[0]],
}]
