# @api private
#
# @summary Install the vnc server pacakges
#
# @param manage_packages
#   Should this class manage the packages
# @param packages
#   List of packages to install
# @param packages_ensure
#   Ensure state of the vnc server packages
class vnc::server::install (
  # lint:ignore:parameter_types
  $manage_packages = $vnc::server::manage_packages,
  $packages = $vnc::server::packages,
  $packages_ensure = $vnc::server::packages_ensure,
  # lint:endignore
) inherits vnc::server {
  assert_private()

  if $manage_packages {
    ensure_packages($packages, { 'ensure' => $packages_ensure })
  }
}
