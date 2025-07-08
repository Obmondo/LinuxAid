# @summary Class for managing walinuxagent software configuration
#
# @param enable Whether to enable walinuxagent. Defaults to false.
#
# @param manage Whether to manage walinuxagent. Defaults to false.
#
# @param noop_value Optional boolean for noop mode. Defaults to undef.
#
# @param $__linux_azure_package
# The Linux Azure package name. Defaults to undef.
#
# @param $__linux_azure_service
# The Linux Azure service name. Defaults to undef.
#
# @param waagent_memory_limit Optional memory limit for waagent. Defaults to undef.
#
class common::software::walinuxagent (
  Boolean                           $enable                 = false,
  Boolean                           $manage                 = false,
  Optional[Boolean]                 $noop_value             = undef,
  Eit_types::SimpleString           $__linux_azure_package  = undef,
  Eit_types::SimpleString           $__linux_azure_service  = undef,
  Optional[String]                  $waagent_memory_limit   = undef,
) inherits common {
  if $manage {
    contain profile::software::walinuxagent
  }
}
