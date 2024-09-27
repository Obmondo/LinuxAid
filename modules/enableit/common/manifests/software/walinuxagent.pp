# walinuxagent
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
