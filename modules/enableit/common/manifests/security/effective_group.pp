# @summary Class for managing the effective group ID setting
#
# @param enable Enable or disable effective group ID configuration. Defaults to false.
#
# @param group_mappings A hash mapping group names to arrays of associated groups.
#
# @param noop_value Optional parameter to set noop mode. Defaults to undef.
#
# @groups general enable, noop_value
#
# @groups mappings group_mappings
#
class common::security::effective_group (
  Boolean                     $enable         = false,
  Hash[String, Array[String]] $group_mappings = {},
  Eit_types::Noop_Value       $noop_value     = undef,
) {
  File {
    ensure => ensure_file($enable),
    noop   => $noop_value,
  }
  file { '/etc/profile.d/effective_group.sh':
    source => 'puppet:///modules/common/security/profile_d_effective_group',
  }
  file { '/etc/default/effective_group':
    content => $group_mappings.map |$group, $list| {
      "${group}=${list.join('|')}\n"
    }.join(''),
  }
}
