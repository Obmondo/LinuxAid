# @summary Class for managing grubclass common::system::grub
#
# @param parameters Hash of parameters for grub configuration. Defaults to an empty hash.
#
# @groups parameters parameters
#
class common::system::grub (
  Eit_types::Grub::Parameters $parameters = {},
) {

  contain ::profile::system::grub
}
