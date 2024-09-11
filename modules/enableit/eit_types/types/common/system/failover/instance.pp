type Eit_types::Common::System::Failover::Instance = Struct[{
  'interface'         => Eit_types::SimpleString,
  'state'             => Enum['MASTER', 'BACKUP'],
  'virtual_router_id' => Integer[0,default],
  'priority'          => Integer[0,default],
  'auth_type'         => Optional[Enum['PASS']],
  'auth_pass'         => Optional[Eit_types::Password],
  'virtual_ipaddress' => Array[Stdlib::IP::Address],
}]
