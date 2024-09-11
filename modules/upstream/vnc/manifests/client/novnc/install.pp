# @api private
# 
# @summary Install the novnc packages
#
# @param manage_packages
#   Should this class manage the packages
# @param packages
#   List of packages to install
# @param packages_ensure
#   Ensure state of the vnc server packages
class vnc::client::novnc::install (
  # lint:ignore:parameter_types
  $manage_packages = $vnc::client::novnc::manage_packages,
  $packages = $vnc::client::novnc::packages,
  $packages_ensure = $vnc::client::novnc::packages_ensure,
  # lint:endignore
) inherits vnc::client::novnc {
  assert_private()

  if $manage_packages {
    ensure_packages($packages, { 'ensure' => $packages_ensure })
  }
}
