# @summary Class for managing the sudo settings in the common system authentication
#
# @param manage Boolean - If true, will manage the authentication sudo settings. Defaults to true.
#
# @param purge Whether to purge existing sudo configurations. Defaults to false.
#
# @param sudoers The sudoers hash configuration. Defaults to an empty hash.
#
# @param sudoers_d_dir The absolute path to the sudoers.d directory. Defaults to '/etc/obmondo/sudoers.d'.
#
# @param noop_value Noop value for the sudoers rules from `sudoers`. Set it to
#   false to apply sudo rule changes even when the agent runs in noop mode.
#   Defaults to undef (follow the agent's noop setting).
class common::user_management::authentication::sudo (
  Boolean               $manage         = $common::user_management::authentication::manage_sudo,
  Boolean               $purge          = false,
  Eit_types::Sudoers    $sudoers        = {},
  Stdlib::Absolutepath  $sudoers_d_dir  = '/etc/obmondo/sudoers.d',
  Eit_types::Noop_Value $noop_value     = undef,
) {
  if $manage {
    include profile::system::sudoers
  }
}
