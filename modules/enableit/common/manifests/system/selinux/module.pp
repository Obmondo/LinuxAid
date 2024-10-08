# simple wrapper for selinux modules
define common::system::selinux::module (
  Optional[Boolean] $noop_value = undef,
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
