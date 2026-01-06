# @summary Class for managing the Azure Linux VM Patch Extension
#
# @param manage Whether to manage the MsftLinuxPatchAutoAssess service. Defaults to false.
#
# @param enable Whether to enable the MsftLinuxPatchAutoAssess service. Defaults to false.
#
# @groups service manage, enable
#
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
