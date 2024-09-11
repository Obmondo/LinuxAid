# manage grub
class profile::system::grub (
  Hash[
    String,
    Struct[{
      ensure => Boolean,
      value  => Optional[Variant[Array,String,Boolean]],
    }]
  ] $parameters = $::common::system::grub::parameters,
) inherits ::profile::system {

  $parameters.each |$key, $value| {
    kernel_parameter { $key:
      ensure => ensure_present($value['ensure']),
      value  => $value['value']
    }
  }
}
