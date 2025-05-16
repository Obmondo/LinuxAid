# @summary Ensures a couple of mandatory files are present before managing their content.
#
# @param list_of_aliases Hash of [`kmod::alias`](#kmodalias) resources
# @param list_of_blacklists Hash of [`kmod::blacklist`](#kmodblacklist) resources
# @param list_of_installs Hash of [`kmod::install`](#kmodinstall) resources
# @param list_of_loads Hash of [`kmod::load`](#kmodload) resources
# @param list_of_options Hash of [`kmod::option`](#kmodoption) resources
# @param owner Default owner for all files (set via Hiera to allow defaults on all defined types)
# @param group Default group for all files (set via Hiera to allow defaults on all defined types)
# @param directory_mode Default mode for all directories (set via Hiera to allow defaults on all defined types)
# @param file_mode Default mode for all regular files (set via Hiera to allow defaults on all defined types)
# @param exe_mode Default mode for all executable files (set via Hiera to allow defaults on all defined types)
# @param modprobe_d Location of `modprobe.d` directory
# @param modprobe_d_files Default files to create in `modprobe.d` directory
#
# @example
#   include kmod
class kmod (
  Hash                    $list_of_aliases    = {},
  Hash                    $list_of_blacklists = {},
  Hash                    $list_of_installs   = {},
  Hash                    $list_of_loads      = {},
  Hash                    $list_of_options    = {},
  String[1]               $owner              = 'root',
  String[1]               $group              = 'root',
  Stdlib::Filemode        $directory_mode     = '0755',
  Stdlib::Filemode        $file_mode          = '0644',
  Stdlib::Filemode        $exe_mode           = '0755',
  Stdlib::Unixpath        $modprobe_d         = '/etc/modprobe.d',
  Array[Stdlib::Unixpath] $modprobe_d_files   = [
    '/etc/modprobe.d/modprobe.conf',
    '/etc/modprobe.d/aliases.conf',
    '/etc/modprobe.d/blacklist.conf',
  ],
) {
  file { $modprobe_d:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $directory_mode,
  }

  file { $modprobe_d_files:
    ensure => file,
    owner  => $owner,
    group  => $group,
    mode   => $file_mode,
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
