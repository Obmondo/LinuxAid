type Eit_types::Users = Hash[Eit_types::User, Struct[
  {
    ensure              => Optional[Enum['present', 'absent']],
    home                => Optional[Stdlib::Absolutepath],
    shell               => Optional[Stdlib::Absolutepath],
    uid                 => Optional[Eit_types::User],
    gid                 => Optional[Eit_types::Group],
    password_hash       => Optional[String],
    expiry              => Optional[Pattern[/^\d{4}-\d{2}-\d{2}$/]],
    realname            => Optional[String],
    system              => Optional[Boolean],
    sudoroot            => Optional[Variant[Boolean, Enum['nopasswd']]],
    sudo_nopasswd       => Optional[Boolean],
    groups              => Optional[Array[Eit_types::Group]],
    purge_ssh_keys      => Optional[Boolean],
    ssh_authorized_keys => Optional[Array[Eit_types::Ssh_pubkey]],
    noop_value          => Optional[Boolean],
  }]]
