# @summary Class for managing auditd configuration
#
# @param enable Whether to enable auditd. Defaults to false.
#
# @groups configuration enable
#
class common::user_management::security::auditd (
  Boolean                               $enable           = false,
) inherits ::common::user_management::security {

  if $enable {
    class { 'auditd':
      default_audit_profiles => ['simp'],
      root_audit_level       => 'aggressive',
    }
  }
}
