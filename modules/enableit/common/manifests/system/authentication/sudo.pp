# sudo
class common::system::authentication::sudo (
  Boolean              $purge           = false,
  Boolean              $ssh_agent_auth  = false,
  Eit_types::Sudoers   $sudoers         = {},
  Stdlib::Absolutepath $__sudoers_d_dir = '/etc/obmondo/sudoers.d',
) {

  include ::profile::system::sudoers
}
