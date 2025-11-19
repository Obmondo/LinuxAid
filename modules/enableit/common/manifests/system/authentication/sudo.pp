# @summary Class for managing the sudo settings in the common system authentication
#
# @param manage Boolean - If true, will manage the authentication sudo settings. Defaults to true.
#
# @param purge Whether to purge existing sudo configurations. Defaults to false.
#
# @param ssh_agent_auth Whether to enable SSH agent authentication. Defaults to false.
#
# @param sudoers The sudoers hash configuration. Defaults to an empty hash.
#
# @param sudoers_d_dir The absolute path to the sudoers.d directory. Defaults to '/etc/obmondo/sudoers.d'.
#
class common::system::authentication::sudo (
  Boolean              $manage         = true,
  Boolean              $purge          = false,
  Boolean              $ssh_agent_auth = false,
  Eit_types::Sudoers   $sudoers        = {},
  Stdlib::Absolutepath $sudoers_d_dir  = '/etc/obmondo/sudoers.d',
) {
  if $manage {
    include profile::system::sudoers
  }
}
