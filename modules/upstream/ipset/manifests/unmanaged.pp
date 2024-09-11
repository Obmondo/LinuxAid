# Declare an IP set, without managing its content.
#
# Useful when you have a dynamic process that generates an IP set content,
# but still want to define and use it from Puppet.
#
# <aside class="warning">
# When changing IP set attributes (type, options) contents won't be kept,
# set will be recreated as empty.
# </aside>
#
# @param ensure Should the IP set be created or removed ?
# @param type Type of IP set.
# @param options IP set options.
# @param keep_in_sync If ``true``, Puppet will update the IP set in the kernel
#   memory. If ``false``, it will only update the IP sets on the filesystem.
#
# @example
#   ipset::unmanaged { 'unmanaged-ipset-name': }
#
define ipset::unmanaged(
  Enum['present', 'absent'] $ensure = 'present',
  IPSet::Type $type = 'hash:ip',
  IPSet::Options $options = {},
  Boolean $keep_in_sync = true,
) {
  ipset::set { $title:
    ensure          => $ensure,
    set             => '',
    ignore_contents => true,
    type            => $type,
    options         => $options,
    keep_in_sync    => $keep_in_sync,
  }
}
