type Eit_types::Storage::Samba::Share = Struct[{
  comment              => String,
  path                 => Stdlib::Absolutepath,
  browseable           => Boolean,
  create_mask          => Optional[Eit_types::File::Mask],
  force_create_mode    => Optional[Eit_types::File::Mask],
  directory_mask       => Optional[Eit_types::File::Mask],
  force_directory_mode => Optional[Eit_types::File::Mask],
  public               => Optional[Boolean],
  writeable            => Optional[Boolean],
  guest_ok             => Optional[Boolean],
  inherit_acls         => Optional[Boolean],
  valid_users          => Optional[Array[Eit_types::User]],
}]
