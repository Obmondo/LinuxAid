type Eit_types::Storage::Samba::Share = Struct[{
  comment              => String,
  path                 => Stdlib::Absolutepath,
  create_mask          => Eit_types::File::Mask,
  force_create_mode    => Eit_types::File::Mask,
  directory_mask       => Eit_types::File::Mask,
  force_directory_mode => Eit_types::File::Mask,
  public               => Boolean,
  writeable            => Boolean,
  guest_ok             => Boolean,
  browseable           => Boolean,
  valid_users          => Optional[Array[Eit_types::User]],
}]
