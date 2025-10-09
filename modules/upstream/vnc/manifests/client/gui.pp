# @summary Install the VNC GUI clients
#
# @param manage_packages
#   Should this class manage the packages
# @param packages
#   List of packages to install
# @param packages_ensure
#   Ensure state of the vnc client packages
class vnc::client::gui (
  Boolean $manage_packages,
  Array $packages,
  String $packages_ensure,
) {
  if $manage_packages {
    stdlib::ensure_packages($packages, { 'ensure' => $packages_ensure })
  }
}
