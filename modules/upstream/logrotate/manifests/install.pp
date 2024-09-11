# make sure logrotate is installed
class logrotate::install {
  assert_private()

  if $logrotate::manage_package {
    package { $logrotate::package:
      ensure => $logrotate::ensure,
    }
  }
}
