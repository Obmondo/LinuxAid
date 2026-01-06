# @summary Class for managing system failover configuration
#
# @param enable Boolean to enable or disable failover. Defaults to false.
#
# @param instances Hash of failover instances configuration. Defaults to an empty hash.
#
# @groups configuration enable, instances
#
class common::system::failover (
  Boolean $enable       = false,
  Eit_types::Common::System::Failover::Instances $instances = {},
) inherits ::common::system {
  if $enable and !$instances.empty {
    include ::profile::system::failover
  }
}
