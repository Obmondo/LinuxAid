# @summary Class for managing the atop monitoring service
#
# @param install Whether to install atop. Defaults to true.
#
# @param daemon Whether to run atop as a daemon. Defaults to false.
#
# @groups service install, daemon.
#
class common::monitoring::atop (
  Boolean $install = true,
  Boolean $daemon  = false,
) {

  confine(!$install, $daemon,
          'atop must be installed for daemon to be enabled')

  include ::profile::monitoring::atop
}
