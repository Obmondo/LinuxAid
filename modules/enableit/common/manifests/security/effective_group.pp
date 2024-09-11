# Set effective group ID
class common::security::effective_group (
  Boolean                     $enable         = false,
  Hash[String, Array[String]] $group_mappings = {},
  Optional[Boolean]           $noop_value     = undef,
) {

  File {
    ensure => ensure_file($enable),
    noop => $noop_value,
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
