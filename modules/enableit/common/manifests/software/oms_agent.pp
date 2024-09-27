# OMS Agent
class common::software::oms_agent (
  Boolean                           $enable                 = false,
  Boolean                           $manage                 = false,
  Optional[Boolean]                 $noop_value             = undef,
  Optional[Eit_types::SimpleString] $version                = undef,
  Optional[String]                  $workspace_id           = undef,
  Optional[String]                  $workspace_key          = undef,
  Optional[String]                  $checksum               = undef,
) inherits common {

  confine($enable, !$workspace_id, !$workspace_key,
          '`$workspace_id` and `$workspace_key` must be provided')

  if $manage {
    contain common::software::oms_agent::update_check
    contain profile::software::oms_agent
  }

}
