# auditd configuration
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
