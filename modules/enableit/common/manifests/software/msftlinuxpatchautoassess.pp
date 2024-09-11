# Azure Linux VM Patch Extension
class common::software::msftlinuxpatchautoassess (
  Boolean $manage = false,
  Boolean $enable = false,
) inherits common {

  # NOTE: Currently we are only managing MsftLinuxPatchAutoAssess.service using this class.
  # In future we should extend this class to manage the package itself as well.
  # Reference: https://github.com/Azure/LinuxPatchExtension?tab=readme-ov-file#2-build-and-test-locally
  if $manage {
    contain profile::software::msftlinuxpatchautoassess
  }
}
