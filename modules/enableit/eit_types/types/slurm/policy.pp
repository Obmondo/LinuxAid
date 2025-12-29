type Eit_types::Slurm::Policy = Struct[{
  'roles' => Struct[{
    'user'  => Variant[String, Array[String]],
    'admin' => Variant[String, Array[String]],
  }],
  'user' => Struct[{
    'actions' => Variant[String, Array[String]],
  }],
  'admin' => Struct[{
    'actions' => Variant[String, Array[String]],
  }],
}]
