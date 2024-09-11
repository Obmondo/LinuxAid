# IP failover
class profile::system::failover (
  Eit_types::Common::System::Failover::Instances $instances = $::common::system::failover::instances,
) inherits ::profile {

  unless $instances.empty {
    include keepalived
  }

  $instances.each |$_name, $_config| {
    keepalived::vrrp::instance { $_name:
      * => $_config
    }
  }

  firewall_multi { '100 allow vrrp multicast':
    destination => '224.0.0.0/8',
    proto       => 'vrrp',
    jump        => 'accept',
  }

}
