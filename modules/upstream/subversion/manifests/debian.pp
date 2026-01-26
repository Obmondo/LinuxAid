class subversion::debian {
  include ::subversion::base

  package {'subversion-tools':
      ensure => present;
  }
}
