# Kubernetes
class role::virtualization::kubernetes (
  Enum['controller','worker'] $role,
  String                      $discovery_token_hash,
  String                      $token,
  Eit_types::IPPort           $controller_address,
  Boolean                     $install_dashboard,
  String                      $version                    = '1.26.1',
  Eit_types::IPCIDR           $pod_cidr                   = '172.20.0.0/16',
  Boolean                     $expose_https_on_master     = true,
  Boolean                     $expose_http_on_master      = true,
  Array                       $apiserver_extra_args       = [],
  Array[Stdlib::Port]         $extra_public_ports         = [],
  Optional[String]            $etcd_initial_cluster       = undef,
  Optional[Array]             $etcd_peers                 = undef,
  Optional[Array]             $worker_peers               = undef,
  Optional[Array[Variant[
    Stdlib::IP::Address,
    Stdlib::Host
  ]]]                         $allow_k8s_api              = $etcd_peers,
  Optional[Stdlib::Fqdn]      $keycloak_oidc_domain       = undef,
  String                      $keycloak_oidc_client_id    = 'kubernetes',
  Boolean                     $keycloak_oidc_groups_claim = true,
  Optional[String]            $etcdserver_crt             = undef,
  Optional[String]            $etcdserver_key             = undef,
  Optional[String]            $etcdpeer_crt               = undef,
  Optional[String]            $etcdpeer_key               = undef,
  Optional[String]            $etcd_ca_crt                = undef,
  Optional[String]            $etcd_ca_key                = undef,
  Optional[String]            $etcdclient_crt             = undef,
  Optional[String]            $etcdclient_key             = undef,
  Optional[String]            $kubernetes_ca_crt          = undef,
  Optional[String]            $kubernetes_ca_key          = undef,
  Optional[String]            $sa_pub                     = undef,
  Optional[String]            $sa_key                     = undef,
  Optional[Array]             $apiserver_cert_extra_sans  = [],
  Optional[String]            $front_proxy_ca_crt         = undef,
  Optional[String]            $front_proxy_ca_key         = undef,
  Optional[String]            $docker_storage_driver      = undef,
  Optional[String]            $containerd_version         = '1.6.20-1',
  Optional[String]            $image_repository           = 'registry.k8s.io',
  Optional[String]            $containerd_install_method  = 'package',
  Enum['overlayfs', 'zfs']    $containerd_snapshotter     = 'zfs',
) inherits role::virtualization {
  if ($role == 'controller') {
    confine(!$etcd_initial_cluster, 'Kubernetes controller missing etdc_initial_cluster')
    confine(!$discovery_token_hash, 'Kubernetes controller missing discovery_token_hash')
    confine(!$etcd_ca_crt, 'Kubernetes controller missing etdc_ca_crt')
    confine(!$etcd_ca_key, 'Kubernetes controller missing etcd_ca_key')
    confine(!$kubernetes_ca_crt, 'Kubernetes controller missing kubernetes_ca_crt')
    confine(!$kubernetes_ca_key, 'Kubernetes controller missing kubernetes_ca_key')
    confine(!$front_proxy_ca_crt, 'Kubernetes controller missing front_proxy_ca_crt')
    confine(!$front_proxy_ca_key, 'Kubernetes controller missing front_proxy_ca_key')
    confine(!$sa_pub, 'Kubernetes controller missing sa_pub')
    confine(!$sa_key, 'Kubernetes controller missing sa_key')
  }

  confine($facts.dig('os', 'family') != 'Debian', 'Only Debian-based distributions are supported')

  confine($keycloak_oidc_domain, !($keycloak_oidc_client_id and $keycloak_oidc_groups_claim), 'keycloak OIDC domain needs `keycloak_oidc_client_id` and `keycloak_oidc_groups_claim`') #lint:ignore:140chars

  include profile::virtualization::kubernetes
}
