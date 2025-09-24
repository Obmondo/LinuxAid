# @summary Class for setting up common configurations
#
# @param noop_value Boolean value to control noop execution mode. Defaults to false.
#
class common::setup (
  Boolean $noop_value = false,
) {
  include ::common::system::authentication::sudo
  contain ::common::virtualization
  contain ::common::setup::obmondo_admin
}
