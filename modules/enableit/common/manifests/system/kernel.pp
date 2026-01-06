# @summary Class for managing the common system kernel configuration
#
# @param modules A hash defining modules to blacklist, install, or load.
# Defaults to an empty hash.
#
# @param sysctl A hash for sysctl configurations, key-value pairs.
# Defaults to an empty hash.
#
# @groups module_params modules.
#
# @groups sysctl_params sysctl.
#
class common::system::kernel (
  Struct[{
    blacklist => Optional[Array[String]],
    install   => Optional[Array[String]],
    load      => Optional[Array[String]],
  }] $modules = {},

  Hash[Eit_types::SimpleString, Variant[Numeric,String]] $sysctl = {},
) inherits ::common::system {

  $modules.each |$key, $value| {
    $value.each |$module| {
      case $key {
        'blacklist': {
          kmod::blacklist { $module:
            file => "/etc/modprobe.d/obmondo_blacklist_${module}.conf"
          }
        }
        'install': {
          kmod::install { $module:
            file => "/etc/modprobe.d/obmondo_blacklist_${module}.conf"
          }
        }
        'load': {
          kmod::load { $module:
            file => "/etc/modprobe.d/obmondo_blacklist_${module}.conf"
          }
        }
        default: {
          notify { 'Nothing can be done with this option': }
        }
      }
    }
  }
  $sysctl.each |$_k, $_v| {
    sysctl::configuration { $_k:
      value => String($_v);
    }
  }
}
