# OMS Agent
class common::software::oms_agent::update_check (
  Boolean           $enable     = false,
) inherits common {

  contain profile::software::oms_agent::update_check
}
