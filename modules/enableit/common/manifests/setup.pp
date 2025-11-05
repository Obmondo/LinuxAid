# @summary Class for setting up common configurations
#
# @param noop_value Boolean value to control noop execution mode. Defaults to false.
#
class common::setup (
  Boolean $noop_value = false,
) {

  include common::setup::obmondo_admin
  # Create Obmondo group for exporter to run under this group
  group { 'obmondo':
    ensure => present,
    system => true,
    noop   => $noop_value,
  }
}
