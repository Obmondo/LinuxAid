
# @summary KubeAid node role: loads common with every subsystem off by default (see
# common/data/role/role::kubeaid.yaml), so a cluster switches on only what it needs.
#
class role::kubeaid inherits ::role {

  include common::system

  # common only loads user management with monitoring on, which KubeAid nodes leave off;
  # authentication (e.g. sudo) is still switched on per cluster in hiera.
  include common::user_management::authentication
}
