type Eit_types::Slurm::Policy = Struct[{
  'roles' => Optional[Struct[{
    'user'  => Optional[Variant[String, Array[String]]],
    'admin' => Optional[Variant[String, Array[String]]],
  }]],
  'user' => Optional[Struct[{
    'actions' => Variant[String, Array[String]],
  }]],
  'admin' => Optional[Struct[{
    'actions' => Variant[String, Array[String]],
  }]],
}]
