type Eit_types::DeviceLvm =
  Hash[Eit_types::SimpleString, Struct[
    {
    use_luks                 => Boolean,
    vg_name                  => Eit_types::SimpleString,
    lv_name                  => Optional[Eit_types::SimpleString],
    devices                  => Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]],
    snapshot_free_extents    => Optional[Eit_types::Percentage],

    mount                    => Optional[Stdlib::Absolutepath],
    mount_options            => Optional[Eit_types::MountOptions],
    filesystem               => Enum['ext4', 'xfs'],
    filesystem_options       => Optional[String],

    luks_key                 => Optional[Eit_types::Password],
    luks_key_service_url     => Optional[Eit_types::URL],
    luks_key_service_token   => Optional[Eit_types::Password],
    luks_key_service_headers => Optional[Hash[String,String]],

    }
  ]]
