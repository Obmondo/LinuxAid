# @summary Manage kernel module options
#
# @param option Option to manage
# @param value Value of kernel module option
# @param module Kernel module to manage
# @param ensure State of the option
# @param file File to manage
#
# @example
#   kmod::option { 'bond0 mode':
#     module  => 'bond0',
#     option  => 'mode',
#     value   => '1',
#   }
define kmod::option (
  String[1]                 $option,
  Scalar                    $value,
  String[1]                 $module = $name,
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::Unixpath          $file   = "/etc/modprobe.d/${module}.conf",
) {
  include kmod

  kmod::setting { "kmod::option ${title}":
    ensure   => $ensure,
    module   => $module,
    category => 'options',
    file     => $file,
    option   => $option,
    value    => $value,
  }
}
