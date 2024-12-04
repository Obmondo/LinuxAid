type Eit_types::Docker::ComposeInstances = Hash[
  Eit_types::SimpleString,
  Struct[{
    compose_files     => Eit_Files::Source,
    refresh_on_change => Optional[Boolean],
    ensure            => Optional[Eit_types::Ensure],
    envs              => Optional[Hash],
  }]
]
