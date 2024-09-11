# Postgresql pg_hba rule

type Eit_types::Pgsql::Pg_hba = Hash[
  Eit_types::SimpleString,
  Struct[{
    user        => Array[Eit_types::SimpleString],
    database    => Eit_types::SimpleString,
    address     => Eit_types::Host,
    auth_method => Optional[Enum[
      'trust',
      'reject',
      'md5',
      'password',
      'gss',
      'sspi',
      'krb5',
      'ident',
      'peer',
      'ldap',
      'radius',
      'cert',
      'pam'
    ]],
    type        => Optional[Enum['local', 'host', 'hostssl', 'hostnossl']],
  }]
]
