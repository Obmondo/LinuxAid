# @summary Class for managing the sudo settings in the common system authentication
#
# @param purge Whether to purge existing sudo configurations. Defaults to false.
#
# @param ssh_agent_auth Whether to enable SSH agent authentication. Defaults to false.
#
# @param sudoers The sudoers hash configuration. Defaults to an empty hash.
#
# @param __sudoers_d_dir The absolute path to the sudoers.d directory. Defaults to '/etc/obmondo/sudoers.d'.
#
class common::system::authentication::sudo (
  Boolean $purge           = false,
  Boolean $ssh_agent_auth  = false,
  Eit_types::Sudoers $sudoers = {},
  Stdlib::Absolutepath $__sudoers_d_dir = '/etc/obmondo/sudoers.d',
) {
  if lookup('common::system::authentication::sudo::manage', Boolean, undef, true) {
    include profile::system::sudoers
  }
}
