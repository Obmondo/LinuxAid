# OMS Agent
class common::software::teleport (
  Boolean                           $enable        = false,
  Optional[Boolean]                 $noop_value    = undef,
  Optional[String]                  $join_token    = undef,
  Optional[String]                  $ca_pin        = undef,
) inherits common {

  confine($enable, !$join_token, !$ca_pin,
          '`$join_token` and `$ca_pin` must be provided')

  # teleport is only support on systemd nodes
  if $facts['init_system'] == 'systemd' {
    contain profile::software::teleport
  }
}
