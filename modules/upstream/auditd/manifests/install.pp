# NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# @summary Install the auditd packages
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::install {
  assert_private()

  package { $::auditd::package_name:
    ensure => $::auditd::package_ensure
  }
}
