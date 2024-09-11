# IP failover
class common::system::failover (
  Boolean $enable = false,
  Eit_types::Common::System::Failover::Instances $instances = {},
) inherits ::common::system {

  if $enable and !$instances.empty {
    include ::profile::system::failover
  }
}
