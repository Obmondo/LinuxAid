# TODO: Docs
class role::util::kubernetes (
  # Options needed for all roles
  String                      $cluster_public_dns,
  Integer                     $cluster_public_port,
  String                      $version,
  SemVer                      $semver_version = SemVer($version),
  Enum['master','worker']     $role,
  String                      $token,

  # Options for ONLY role=worker
  Optional[String]            $node_join_token = undef,
  Optional[Boolean]           $ceph_client = false,

  # Options for ONLY role=master
  Optional[Hash[String, Struct[{
    role  => Enum['cluster-admin'],
  }]]]                        $users = undef,
  Optional[Eit_types::IPCIDR] $pod_cidr = undef,
  Optional[Eit_types::IPCIDR] $service_cidr = undef,
  # Certificates for this cluster - should be kept ENC[] in yaml files
  # TODO: Mark as secrets somehow here
  # Generated certs (by script in modules/enableit/kubernetes)
  #  - have ALL hostnames needed for all nodes in SAN field (x509) so these can be shared
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
    proto  => 'tcp',
    dport  => 6443,
    jump   => 'accept',
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
