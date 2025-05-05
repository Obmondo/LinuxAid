# @summary Manages the service of Gitlab runner
#
# @api private
#
class gitlab_ci_runner::service (
  $package_name = $gitlab_ci_runner::package_name,
) {
  assert_private()

  if $facts['os']['family'] == 'Suse' {
    exec { "${gitlab_ci_runner::binary_path} install -u ${gitlab_ci_runner::user}":
      creates => '/etc/systemd/system/gitlab-runner.service',
    }
  }
  service { $package_name:
    ensure => running,
    enable => true,
  }
}
