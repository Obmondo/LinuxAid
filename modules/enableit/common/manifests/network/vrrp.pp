# @summary Class for managing VRRP configuration
#
# @param enable Boolean to enable or disable the VRRP setup. Defaults to false.
#
# @param hosts Array of IP addresses for VRRP hosts. Defaults to an empty array.
#
# @param instances Hash defining VRRP instances with their configurations. Defaults to an empty hash.
#
# @param sync_groups Hash defining synchronization groups with their configurations. Defaults to an empty hash.
#
class common::network::vrrp (
  Boolean                    $enable       = false,
  Array[Stdlib::IP::Address] $hosts        = [],
  Hash                       $instances    = {},
  Hash                       $sync_groups  = {},
) inherits ::common::network {

  include keepalived

  class { '::keepalived::global_defs':
    notification_email => 'ops@enableit.dk',
    smtp_server        => 'localhost',
  }

  $instances.each |$_name, $_config| {
    keepalived::vrrp::instance { $_name:
      * => $_config,
    }
  }

  $sync_groups.each |$key, $value| {
    keepalived::vrrp::sync_group { $key:
      * => $value,
    }
  }
}
