class posix_acl::requirements {
  package { 'acl':
    ensure => 'present',
  }
}
