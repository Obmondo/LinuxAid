#
# == Class: kmod
#
# Ensures a couple of mandatory files are present before managing their
# content.
#
#
class kmod (
  Optional[Hash] $list_of_aliases    = {},
  Optional[Hash] $list_of_blacklists = {},
  Optional[Hash] $list_of_installs   = {},
  Optional[Hash] $list_of_loads      = {},
  Optional[Hash] $list_of_options    = {},
){
  file { '/etc/modprobe.d': ensure => directory }

  file { [
      '/etc/modprobe.d/modprobe.conf',
      '/etc/modprobe.d/aliases.conf',
      '/etc/modprobe.d/blacklist.conf',
    ]: ensure => file,
  }

  $list_of_aliases.each | $name, $data | {
    kmod::alias { $name:
      * => $data,
    }
  }
  $list_of_blacklists.each | $name, $data | {
    kmod::blacklist { $name:
      * => $data,
    }
  }
  $list_of_installs.each | $name, $data | {
    kmod::install { $name:
      * => $data,
    }
  }
  $list_of_loads.each | $name, $data | {
    kmod::load { $name:
      * => $data,
    }
  }
  $list_of_options.each | $name, $data | {
    kmod::option { $name:
      * => $data,
    }
  }
}
