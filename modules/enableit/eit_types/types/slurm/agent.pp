type Eit_types::Slurm::Agent = Struct[{
  'service'    => Struct[{
    'cluster' => String,
  }],
  'slurmrestd' => Struct[{
    'jwt_mode'  => Enum['static', 'dynamic'],
    'jwt_token' => String,
  }],
}]
