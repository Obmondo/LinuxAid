# @summary Class for managing the atop monitoring service
#
# @param daemon Whether to run atop as a daemon. Defaults to false.
#
# @groups service daemon.
#
class common::system::utility::atop (
  Boolean $daemon = false,
) {

  $install = false

  confine(!$install, $daemon,
          'atop must be installed for daemon to be enabled')

  include ::profile::system::utility::atop
}
