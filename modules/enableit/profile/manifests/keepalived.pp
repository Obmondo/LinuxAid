# KeepAlived
class profile::keepalived (
  Hash $global_defs = $::common::keepalived::global_defs,
  Hash $sync_groups = $::common::keepalived::sync_groups,
  Hash $instances   = $::common::keepalived::instances,
) {

  include ::keepalived

  class { '::keepalived::global_defs':
    notification_email      => $global_defs['notification_email'],
    notification_email_from => $global_defs['notification_email_from'],
    smtp_server             => $global_defs['smtp_server'],
    smtp_connect_timeout    => $global_defs['smtp_connect_timeout'],
    router_id               => $global_defs['router_id'],
  }

  $instances.each |$key, $value| {
    keepalived::vrrp::instance { $key:
      * => $value,
    }
  }

  $sync_groups.each |$key, $value| {
    keepalived::vrrp::sync_group { $key:
      * => $value,
    }
  }
}
