
# @summary Class for managing the Kubernetes role
#
# @param role The role of the node (either 'controller' or 'worker').
#
# @param discovery_token_hash The discovery token hash for the controller.
#
# @param token The token for authentication.
#
# @param controller_address The IP address and port of the controller.
#
# @param install_dashboard Boolean to indicate if the Kubernetes dashboard should be installed.
#
# @param version The version of Kubernetes to install. Defaults to '1.26.1'.
#
# @param pod_cidr The CIDR block for the pod network. Defaults to '172.20.0.0/16'.
#
# @param expose_https_on_master Boolean to indicate if HTTPS should be exposed on the master. Defaults to true.
#
# @param expose_http_on_master Boolean to indicate if HTTP should be exposed on the master. Defaults to true.
#
# @param apiserver_extra_args An array of extra arguments for the API server.
#
# @param extra_public_ports An array of extra public ports to expose.
#
# @param etcd_initial_cluster The initial cluster for etcd. Defaults to undef.
#
# @param etcd_peers An array of etcd peer nodes. Defaults to undef.
#
# @param worker_peers An array of worker peer nodes. Defaults to undef.
#
# @param allow_k8s_api An array of hosts or IPs allowed to access the Kubernetes API. Defaults to etcd_peers.
#
# @param keycloak_oidc_domain The OIDC domain for Keycloak. Defaults to undef.
#
# @param keycloak_oidc_client_id The client ID for OIDC in Keycloak. Defaults to 'kubernetes'.
#
# @param keycloak_oidc_groups_claim Boolean to indicate if group claims are included in the OIDC token. Defaults to true.
#
# @param etcdserver_crt The certificate for the etcd server. Defaults to undef.
#
# @param etcdserver_key The key for the etcd server. Defaults to undef.
#
# @param etcdpeer_crt The certificate for etcd peers. Defaults to undef.
#
# @param etcdpeer_key The key for etcd peers. Defaults to undef.
#
# @param etcd_ca_crt The CA certificate for etcd. Defaults to undef.
#
# @param etcd_ca_key The CA key for etcd. Defaults to undef.
#
# @param etcdclient_crt The certificate for the etcd client. Defaults to undef.
#
# @param etcdclient_key The key for the etcd client. Defaults to undef.
#
# @param kubernetes_ca_crt The CA certificate for Kubernetes. Defaults to undef.
#
# @param kubernetes_ca_key The CA key for Kubernetes. Defaults to undef.
#
# @param sa_pub The public key for the service account. Defaults to undef.
#
# @param sa_key The private key for the service account. Defaults to undef.
#
# @param apiserver_cert_extra_sans An array of extra Subject Alternative Names for the API server certificate. Defaults to an empty array.
#
# @param front_proxy_ca_crt The CA certificate for the front proxy. Defaults to undef.
#
# @param front_proxy_ca_key The CA key for the front proxy. Defaults to undef.
#
# @param docker_storage_driver The storage driver for Docker. Defaults to undef.
#
# @param containerd_version The version of containerd to install. Defaults to '1.6.20-1'.
#
# @param image_repository The image repository to use. Defaults to 'registry.k8s.io'.
#
# @param containerd_install_method The method to install containerd. Defaults to 'package'.
#
# @param containerd_snapshotter The snapshotter to use for containerd. Defaults to 'zfs'.
#
class role::virtualization::kubernetes (
  Enum['controller','worker'] $role,
  Sensitive[String]           $discovery_token_hash,
  Sensitive[String]           $token,
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
  Optional[Array[Variant[    Stdlib::IP::Address,    Stdlib::Host  ]]]                         $allow_k8s_api              = $etcd_peers,
  Optional[Stdlib::Fqdn]      $keycloak_oidc_domain       = undef,
  String                      $keycloak_oidc_client_id    = 'kubernetes',
  Boolean                     $keycloak_oidc_groups_claim = true,
  Optional[String]            $etcdserver_crt             = undef,
  Optional[Sensitive[String]] $etcdserver_key             = undef,
  Optional[String]            $etcdpeer_crt               = undef,
  Optional[Sensitive[String]] $etcdpeer_key               = undef,
  Optional[String]            $etcd_ca_crt                = undef,
  Optional[Sensitive[String]] $etcd_ca_key                = undef,
  Optional[String]            $etcdclient_crt             = undef,
  Optional[Sensitive[String]] $etcdclient_key             = undef,
  Optional[String]            $kubernetes_ca_crt          = undef,
  Optional[Sensitive[String]] $kubernetes_ca_key          = undef,
  Optional[String]            $sa_pub                     = undef,
  Optional[Sensitive[String]] $sa_key                     = undef,
  Optional[Array]             $apiserver_cert_extra_sans  = [],
  Optional[String]            $front_proxy_ca_crt         = undef,
  Optional[Sensitive[String]] $front_proxy_ca_key         = undef,
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
  confine($keycloak_oidc_domain, !($keycloak_oidc_client_id and $keycloak_oidc_groups_claim), 'keycloak OIDC domain needs `keycloak_oidc_client_id` and `keycloak_oidc_groups_claim`')

  #lint:ignore:140chars  
  include profile::virtualization::kubernetes
}
