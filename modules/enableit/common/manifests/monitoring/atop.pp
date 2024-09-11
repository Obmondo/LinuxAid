# atop
class common::monitoring::atop (
  Boolean $install = true,
  Boolean $daemon = false,
) {

  confine(!$install, $daemon,
          'atop must be installed for daemon to be enabled')

  include ::profile::monitoring::atop
}
