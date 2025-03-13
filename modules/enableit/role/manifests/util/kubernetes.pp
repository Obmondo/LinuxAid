
# @summary Class for managing the Kubernetes role
#
# @param cluster_public_dns The public DNS for the cluster.
#
# @param cluster_public_port The public port for the cluster.
#
# @param version The version of Kubernetes.
#
# @param semver_version The semantic version of Kubernetes. Defaults to SemVer($version).
#
# @param role The role of the node. Can be 'master' or 'worker'.
#
# @param token The token for authentication.
#
# @param node_join_token The join token for worker nodes. Defaults to undef.
#
# @param ceph_client Boolean to enable Ceph client. Defaults to false.
#
# @param users The users for the cluster if role is master. Defaults to undef.
#
# @param pod_cidr The CIDR for pods. Defaults to undef.
#
# @param service_cidr The CIDR for services. Defaults to undef.
#
# @param etcd_ca_crt The CA certificate for etcd. Defaults to undef.
#
# @param etcd_ca_key The CA key for etcd. Defaults to undef.
#
# @param apiserver2etcd_crt The certificate for API server to etcd. Defaults to undef.
#
# @param apiserver2etcd_key The key for API server to etcd. Defaults to undef.
#
# @param etcdpeer_crt The certificate for etcd peers. Defaults to undef.
#
# @param etcdpeer_key The key for etcd peers. Defaults to undef.
#
# @param kubernetes_ca_crt The CA certificate for Kubernetes. Defaults to undef.
#
# @param kubernetes_ca_key The CA key for Kubernetes. Defaults to undef.
#
# @param sa_pub The public key for service account. Defaults to undef.
#
# @param sa_key The private key for service account. Defaults to undef.
#
# @param front_proxy_ca_crt The CA certificate for the front proxy. Defaults to undef.
#
# @param front_proxy_ca_key The CA key for the front proxy. Defaults to undef.
#
class role::util::kubernetes (
  String                      $cluster_public_dns,
  Integer                     $cluster_public_port,
  String                      $version,
  SemVer                      $semver_version = SemVer($version),
  Enum['master','worker']     $role,
  String                      $token,
  Optional[String]            $node_join_token = undef,
  Optional[Boolean]           $ceph_client = false,
  Optional[Hash[String, Struct[{ role => Enum['cluster-admin'], }]]] $users = undef,
  Optional[Eit_types::IPCIDR] $pod_cidr = undef,
  Optional[Eit_types::IPCIDR] $service_cidr = undef,
  Optional[String]            $etcd_ca_crt = undef,
  Optional[String]            $etcd_ca_key = undef,
  Optional[String]            $apiserver2etcd_crt = undef,
  Optional[String]            $apiserver2etcd_key = undef,
  Optional[String]            $etcdpeer_crt = undef,
  Optional[String]            $etcdpeer_key = undef,
  Optional[String]            $kubernetes_ca_crt = undef,
  Optional[String]            $kubernetes_ca_key = undef,
  Optional[String]            $sa_pub = undef,
  Optional[String]            $sa_key = undef,
  Optional[String]            $front_proxy_ca_crt = undef,
  Optional[String]            $front_proxy_ca_key = undef,
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
    kubernetes_version  => $semver_version,
    cluster_public_dns  => $cluster_public_dns,
    cluster_public_port => $cluster_public_port,
    controller          => $controller,
    worker              => $worker,
    node_join_token     => $node_join_token,
    pod_cidr            => $pod_cidr,
    service_cidr        => $service_cidr,
    cni_provider        => 'calico',
    token               => $token,
    etcd_ca_crt         => $etcd_ca_crt,
    etcd_ca_key         => $etcd_ca_key,
    apiserver2etcd_crt  => $apiserver2etcd_crt,
    apiserver2etcd_key  => $apiserver2etcd_key,
    etcdpeer_crt        => $etcdpeer_crt,
    etcdpeer_key        => $etcdpeer_key,
    kubernetes_ca_crt   => $kubernetes_ca_crt,
    kubernetes_ca_key   => $kubernetes_ca_key,
    sa_pub              => $sa_pub,
    sa_key              => $sa_key,
    front_proxy_ca_crt  => $front_proxy_ca_crt,
    front_proxy_ca_key  => $front_proxy_ca_key,
  }

  #add support for using ceph storage
  if $ceph_client {
    include ::profile::storage::ceph_client
  }
}
