# @summary Configures the audit dispatcher primarily for sending audit logs directly to syslog without intervention.
#
# The following parameters are documented in audispd.conf(5).
#
# These settings are deprecated and will be removed in the next major release
# of auditd and are here for backwards compatability.
#
# In auditd version 3  these settings were moved to auditd.conf
# and audisp.conf was deprecated.  For this reason they are set in the init.pp
# module with the other auditd.conf values also.  If you are trying to set these values
# for auditd version 3 then you must set them there.
# These settings are aliased in
# hiera to auditd settings so you can move your settings
# for these parameters to auditd::* now to ensure compatability with
# future major releases but settings in hiera that are already exist will still work.
# @param q_depth
#        (deprecated)
# @param overflow_action
#        (deprecated)
# @param priority_boost
#        (deprecated)
# @param max_restarts
#        (deprecated)
# @param name_format
#        (deprecated)
#
# The following setting maps to the name variable in audisp.conf.
# @param specific_name
#
# @author https://github.com/simp/pupmod-simp-auditd/graphs/contributors
#
class auditd::config::audisp (
  Integer                $q_depth,
  Auditd::OverflowAction $overflow_action,
  Integer                $priority_boost,
  Integer                $max_restarts,
  Auditd::NameFormat     $name_format,
  String                 $specific_name    = $facts['fqdn']
) {

  if  versioncmp($facts['auditd_version'], '3.0') < 0 {
    include auditd::config::audisp_service

    file { '/etc/audisp/audispd.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => "# This file managed by Puppet
q_depth         = ${q_depth}
overflow_action = ${overflow_action}
priority_boost  = ${priority_boost}
max_restarts    = ${max_restarts}
name_format     = ${name_format}
name            = ${specific_name}
"
    }
  }
}
