# VRRP
#
# Example hiera config:
#
#   common::network::vrrp::hosts:
#     - '172.17.5.164'
#     - '172.17.5.165'
#   common::network::vrrp::instances:
#     'VI_50':
#       interface: 'eth0'
#       state: 'MASTER'
#       virtual_router_id: 61
#       priority: 101
#       auth_type: 'PASS'
#       auth_pass: 'secret'
#       virtual_ipaddress:
#         - '172.17.5.200/23'
#     'VI_51':
#       interface: 'eth0'
#       state: 'BACKUP'
#       virtual_router_id: 60
#       priority: 100
#       auth_type: 'PASS'
#       auth_pass: 'secret'
#       virtual_ipaddress:
#         - '172.17.5.201/23'
class common::network::vrrp (
  Boolean                    $enable      = false,
  Array[Stdlib::IP::Address] $hosts       = [],
  Hash                       $instances   = {},
  Hash                       $sync_groups = {},
) inherits ::common::network {

  include keepalived

  class { '::keepalived::global_defs':
    notification_email => 'ops@enableit.dk',
    smtp_server        => 'localhost'
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
