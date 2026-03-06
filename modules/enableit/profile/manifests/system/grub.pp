# manage grub
class profile::system::grub (
  Eit_types::Grub::Parameters $parameters = $::common::system::grub::parameters,
) {

  $parameters.each |$key, $value| {
    kernel_parameter { $key:
      ensure => ensure_present($value['ensure']),
      value  => $value['value']
    }
  }
}
