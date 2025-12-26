type Eit_types::Slurm::Gateway = Struct[{
  'service' => Struct[{
    'interface' => String,
    'port'      => Optional[Integer],
  }],
  'ui' => Struct[{
    'host' => String,
  }],
  'authentication' => Struct[{
    'enabled' => Boolean,
  }],
  'ldap' => Optional[Struct[{
    'uri'                      => String,
    'user_base'                => String,
    'group_base'               => String,
    'group_name_attribute'     => Optional[String],
    'user_class'               => Optional[String],
    'group_object_classes'     => Optional[String],
    'user_name_attribute'      => Optional[String],
    'user_fullname_attribute'  => Optional[String],
    'user_primary_group_attribute' => Optional[String],
    'starttls'                 => Optional[Boolean],
    'bind_dn'                  => String,
    'bind_password'            => String,
  }]],
  'agents' => Struct[{
    'url' => String,
  }],
}]
