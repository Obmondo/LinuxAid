# Kernel
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
