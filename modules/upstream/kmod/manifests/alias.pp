# @summary Manage kernel module aliases
#
# @param source Name of the module to alias
# @param ensure State of the alias
# @param file File to manage
# @param aliasname Name of the alias (defaults to the resource title)
#
# @example
#   kmod::alias { 'bond0':
#     source => 'bonding',
#   }
define kmod::alias (
  String[1]                 $source,
  Enum['present', 'absent'] $ensure    = 'present',
  Stdlib::Unixpath          $file      = "/etc/modprobe.d/${name}.conf",
  String[1]                 $aliasname = $name,
) {
  include kmod

  kmod::setting { "kmod::alias ${title}":
    ensure   => $ensure,
    module   => $aliasname,
    file     => $file,
    category => 'alias',
    option   => 'modulename',
    value    => $source,
  }
}
