# Azure Linux VM Patch Extension
class profile::software::msftlinuxpatchautoassess (
  Boolean $enable = $common::software::msftlinuxpatchautoassess::enable,
) {

  service { 'MsftLinuxPatchAutoAssess.service':
    ensure => ensure_service($enable),
    enable => true,
  }
}
