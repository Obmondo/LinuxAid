
# @summary KubeAid node role: loads common with every subsystem off by default (see
# common/data/role/role::kubeaid.yaml), so a cluster switches on only what it needs.
#
class role::kubeaid inherits ::role {

  include common::system

  # common only loads user management with monitoring on, which KubeAid nodes leave off;
  # authentication (e.g. sudo) is still switched on per cluster in hiera.
  include common::user_management::authentication

  # profile::system::sudoers requires the sudoers.d directory, which common only creates
  # with monitoring on.
  if $common::user_management::authentication::manage
    and $common::user_management::authentication::manage_sudo
    and !defined(File['/etc/obmondo/sudoers.d']) {
    file { ['/etc/obmondo', '/etc/obmondo/sudoers.d']:
      ensure => directory,
    }
  }
}
