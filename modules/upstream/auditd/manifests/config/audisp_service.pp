# NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# @summary  Notify auditd to restart to ensure the process for audisp
#           is running.
#
# Should only be called from audisp processing services.
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::config::audisp_service {
  assert_private()

  # This is needed just in case the audit dispatcher fails at some point.
  exec { 'Restart Audispd':
    command => '/bin/true',
    unless  => "/usr/bin/pgrep -f ${auditd::dispatcher}",
    notify  => Class['auditd::service']
  }

}
