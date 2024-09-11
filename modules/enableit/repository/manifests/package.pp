# Install required package
class repository::package {

  package { [
      'rpm',
      'debmirror',
    ]:
    ensure => installed,

  }
}
