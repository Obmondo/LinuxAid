# NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# @summary Ensures that plugin for syslog is installed so audit events
#          can be sent to syslog in addition the audit partition.
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::config::logging {
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
  assert_private()

  # auditd_version fact is not available until auditing is enabled in the kernel
  if $facts['auditd_version'] {
    if  versioncmp($facts['auditd_version'], '3.0') < 0 {
      contain 'auditd::config::audisp'
    }
    contain 'auditd::config::audisp::syslog'
  }
}
