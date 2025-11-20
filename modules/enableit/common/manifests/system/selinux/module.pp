# @summary Class for managing SELinux modules
#
# @param noop_value Optional boolean to control noop behavior, defaults to undef.
#
define common::system::selinux::module (
  Eit_types::Noop_Value $noop_value = undef,
) {
  if lookup('common::system::selinux::enable', Boolean, undef, false) {
    include common::system::selinux
    if $noop_value == false {
      Exec {
        noop => false,
      }
      File {
        noop => false,
      }
      Selmodule {
        noop => false,
      }
    }
    selinux::module { $title:
      ensure    => 'present',
      source_te => "puppet:///modules/common/system/selinux/${title}.te",
      builder   => 'simple',
    }
  }
}
