# @summary Class for managing the OMS Agent
#
# @param enable
# Whether to enable the OMS Agent. Defaults to false.
#
# @param noop_value Optional boolean for noop mode. Defaults to undef.
#
# @param join_token Optional string for the join token. Defaults to undef.
#
# @param ca_pin Optional string for the CA pin. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
class common::software::teleport (
  Boolean                           $enable        = false,
  Eit_types::Noop_Value             $noop_value    = undef,
  Optional[String]                  $join_token    = undef,
  Optional[String]                  $ca_pin        = undef,
  Eit_types::Encrypt::Params        $encrypt_params = ['join_token','ca_pin'],
) inherits common {
  confine($enable, !$join_token, !$ca_pin, '`$join_token` and `$ca_pin` must be provided')
  # teleport is only support on systemd nodes
  if $facts['init_system'] == 'systemd' {
    contain profile::software::teleport
  }
}
