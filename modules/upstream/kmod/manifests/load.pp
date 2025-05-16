# @summary Manage a kernel module in /etc/modules.
#
# @param ensure State of the setting
#
# @example
#   kmod::load { 'sha256': }
define kmod::load (
  Enum['present', 'absent'] $ensure = 'present',
) {
  include kmod

  case $ensure {
    'present': {
      case $facts['os']['family'] {
        'Debian': {
          $changes = "clear '${name}'"
        }
        'Suse': {
          $changes = "set MODULES_LOADED_ON_BOOT/value[.='${name}'] '${name}'"
        }
        default: {}
      }

      exec { "modprobe ${name}":
        path   => '/bin:/sbin:/usr/bin:/usr/sbin',
        unless => "grep -qE '^${name} ' /proc/modules",
      }
    }

    'absent': {
      case $facts['os']['family'] {
        'Debian': {
          $changes = "rm '${name}'"
        }
        'Suse': {
          $changes = "rm MODULES_LOADED_ON_BOOT/value[.='${name}']"
        }
        default: {}
      }

      exec { "modprobe -r ${name}":
        path   => '/bin:/sbin:/usr/bin:/usr/sbin',
        onlyif => "grep -qE '^${name} ' /proc/modules",
      }
    }

    default: { fail "${module_name}: unknown ensure value ${ensure}" }
  }

  file { "/etc/modules-load.d/${name}.conf":
    ensure  => $ensure,
    mode    => $kmod::file_mode,
    owner   => $kmod::owner,
    group   => $kmod::group,
    content => "# This file is managed by the puppet kmod module.\n${name}\n",
  }
}
