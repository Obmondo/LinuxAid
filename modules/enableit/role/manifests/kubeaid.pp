
# @summary KubeAid node role: loads common with every subsystem off by default (see
# common/data/role/role::kubeaid.yaml), so a cluster switches on only what it needs.
#
class role::kubeaid inherits ::role {

  include common::system
}
