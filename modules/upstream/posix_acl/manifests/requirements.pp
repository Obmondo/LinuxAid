#
# @summary install the acl package
#
class posix_acl::requirements {
  package { 'acl':
    ensure => 'present',
  }
}
