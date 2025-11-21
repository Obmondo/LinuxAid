# @summary Class for managing fwupd refresh process
#
# @param manage Whether to manage the fwupd profile. Defaults to false.
#
# @param enable Whether to enable the fwupd refresh. Defaults to false.
#
# @param noop_value Optional parameter to specify noop mode value.
#
class common::software::fwupd (
  Boolean               $manage     = false,
  Boolean               $enable     = false,
  Eit_types::Noop_Value $noop_value = undef,
) inherits common {

  if $manage {
    contain profile::software::fwupd
  }
}
