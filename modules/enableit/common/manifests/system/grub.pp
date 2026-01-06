# @summary Class for managing grubclass common::system::grub
#
# @param parameters Hash of parameters for grub configuration. Defaults to an empty hash.
#
# @groups parameters parameters
#
class common::system::grub (
  Hash[String, Struct[
    {
      ensure  => Optional[Boolean],
      value   => Optional[Variant[Array, String, Boolean]],
    }
  ]] $parameters = {},
) inherits ::common::system {

  contain ::profile::system::grub
}
