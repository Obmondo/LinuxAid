# @summary Class for managing auditd configuration
#
# @param enable Whether to enable auditd. Defaults to false.
#
# @param root_audit_level The audit level for root. Can be 'basic', 'aggressive', or 'insane'. Defaults to 'aggressive'.
#
class common::security::auditd (
  Boolean                               $enable           = false,
  Enum['basic', 'aggressive', 'insane'] $root_audit_level = 'aggressive',
) inherits ::common::security {

  if $enable {
    class { 'auditd':
      default_audit_profiles => ['simp'],
      root_audit_level       => $root_audit_level,
    }
  }
}
