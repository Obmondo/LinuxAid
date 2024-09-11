# manage grub
class common::system::grub (
  Hash[
    String,
    Struct[{
      ensure => Optional[Boolean],
      value  => Optional[Variant[Array,String,Boolean]],
    }]
  ]       $parameters = {},
) inherits ::common::system {

  contain ::profile::system::grub
}
