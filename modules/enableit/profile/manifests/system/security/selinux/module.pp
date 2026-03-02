# @summary Class for managing SELinux modules
#
# @param noop_value Optional boolean to control noop behavior, defaults to undef.
define profile::system::security::selinux::module (
  Eit_types::Noop_Value $noop_value = undef,
) {
  if lookup('common::user_management::security::selinux::enable', Boolean, undef, false) {
    include common::user_management::security::selinux

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
