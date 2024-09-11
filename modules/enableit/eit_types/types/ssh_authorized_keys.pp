# SSH authroized keys
type Eit_types::Ssh_authorized_keys = Hash[String, Struct[{
  user       => Eit_types::User,
  key        => String,
  options    => Optional[Hash],
  noop_value => Optional[Boolean],
}]]
