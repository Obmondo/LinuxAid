# @summary Manages the service of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::service (
  $package_name = $gitlab_ci_runner::package_name,
) {
  assert_private()

  service { $package_name:
    ensure => running,
    enable => true,
  }
}
