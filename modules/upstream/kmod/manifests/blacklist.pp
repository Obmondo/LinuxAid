# @summary Set a kernel module as blacklisted.
#
# @param ensure State of the setting
# @param file File to manage
#
# @example
#   kmod::blacklist { 'pcspkr': }
define kmod::blacklist (
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::Unixpath          $file   = '/etc/modprobe.d/blacklist.conf',
) {
  include kmod

  kmod::setting { "kmod::blacklist ${title}":
    ensure   => $ensure,
    module   => $name,
    file     => $file,
    category => 'blacklist',
  }
}
