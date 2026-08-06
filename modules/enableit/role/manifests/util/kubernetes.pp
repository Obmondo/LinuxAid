
# @summary Class for managing the Kubernetes role
#
# @param cluster_public_dns The public DNS for the cluster.
#
# @param cluster_public_port The public port for the cluster.
#
# @param version The version of Kubernetes.
#
# @param role The role of the node. Can be 'master' or 'worker'.
#
# @param token The token for authentication.
#
# @param ceph_client Boolean to enable Ceph client. Defaults to false.
#
# @groups cluster_info cluster_public_dns, cluster_public_port, version.
#
# @groups role_info role, token, ceph_client.
#
class role::util::kubernetes (
  String                  $cluster_public_dns,
  Integer                 $cluster_public_port,
  String                  $version,
  Enum['master','worker'] $role,
  String                  $token,
  Optional[Boolean]       $ceph_client = false,
) inherits ::role::util {

  # We need anyone to be able to reach k8s controller api
  firewall { '010 allow k8s controller api':
    proto => 'tcp',
    dport => 6443,
    jump  => 'accept',
  }

  #TODO: use our logic function to validate correct variables role selected
  $controller = $role == 'master'
  $worker = $role == 'worker'

  class { '::kubernetes':
    kubernetes_version  => SemVer($version),
    cluster_public_dns  => $cluster_public_dns,
    cluster_public_port => $cluster_public_port,
    controller          => $controller,
    worker              => $worker,
    node_join_token     => undef,
    pod_cidr            => undef,
    service_cidr        => undef,
    cni_provider        => 'calico',
    token               => $token,
    etcd_ca_crt         => undef,
    etcd_ca_key         => undef,
    apiserver2etcd_crt  => undef,
    apiserver2etcd_key  => undef,
    etcdpeer_crt        => undef,
    etcdpeer_key        => undef,
    kubernetes_ca_crt   => undef,
    kubernetes_ca_key   => undef,
    sa_pub              => undef,
    sa_key              => undef,
    front_proxy_ca_crt  => undef,
    front_proxy_ca_key  => undef,
  }

  #add support for using ceph storage
  if $ceph_client {
    include ::profile::storage::ceph_client
  }
}
