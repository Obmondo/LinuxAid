# @summary Set a kernel module as installed
#
# @param ensure State of the setting
# @param command Command associated with the kernel module
# @param file File where the stanza is written
#
# @example
#   kmod::install { 'pcspkr': }
define kmod::install (
  Enum['present', 'absent'] $ensure  = 'present',
  String[1]                 $command = '/bin/true',
  Stdlib::Unixpath          $file    = "/etc/modprobe.d/${name}.conf",
) {
  include kmod

  kmod::setting { "kmod::install ${title}":
    ensure   => $ensure,
    module   => $name,
    file     => $file,
    category => 'install',
    option   => 'command',
    value    => $command,
  }
}
