# Postgresql DB

type Eit_types::Pgsql::Db = Hash[
  Eit_types::SimpleString,
  Struct[{
    user     => Eit_types::SimpleString,
    password => Eit_types::Password,
    grant    => Optional[String],
  }]
]
