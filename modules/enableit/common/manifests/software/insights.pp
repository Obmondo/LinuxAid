# @summary Class for managing insights client access
#
# @param manage Enable or manage Insights client. Defaults to false.
#
# @param enable Enable or disable Insights client. Defaults to false.
#
# @param noop_value Optional boolean for noop value. Defaults to undef.
#
# @groups client manage, enable.
#
# @groups optional noop_value.
#
class common::software::insights (
  Boolean               $manage     = false,
  Boolean               $enable     = false,
  Eit_types::Noop_Value $noop_value = undef,
) {
  if $manage {
    if $facts['os']['family'] == 'RedHat' {
      contain profile::software::insights
    }
  }
}
