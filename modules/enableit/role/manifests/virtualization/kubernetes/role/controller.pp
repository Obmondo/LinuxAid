# @summary Control-plane settings, used when `role` is 'controller'
#
# @param etcd_initial_cluster The initial etcd cluster string. Defaults to undef.
#
# @param etcd_ca_crt The etcd CA certificate. Defaults to undef.
#
# @param etcd_ca_key The etcd CA key. Defaults to undef.
#
# @param kubernetes_ca_crt The Kubernetes CA certificate. Defaults to undef.
#
# @param kubernetes_ca_key The Kubernetes CA key. Defaults to undef.
#
# @param front_proxy_ca_crt The front-proxy CA certificate. Defaults to undef.
#
# @param front_proxy_ca_key The front-proxy CA key. Defaults to undef.
#
# @param sa_pub The service account public key. Defaults to undef.
#
# @param sa_key The service account private key. Defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups controller etcd_initial_cluster, etcd_ca_crt, etcd_ca_key, kubernetes_ca_crt, kubernetes_ca_key, front_proxy_ca_crt, front_proxy_ca_key, sa_pub, sa_key, encrypt_params
#
# @encrypt_params etcd_ca_key, kubernetes_ca_key, front_proxy_ca_key, sa_key
#
class role::virtualization::kubernetes::role::controller (
  Optional[String] $etcd_initial_cluster = undef,
  Optional[String] $etcd_ca_crt          = undef,
  Optional[String] $etcd_ca_key          = undef,
  Optional[String] $kubernetes_ca_crt    = undef,
  Optional[String] $kubernetes_ca_key    = undef,
  Optional[String] $front_proxy_ca_crt   = undef,
  Optional[String] $front_proxy_ca_key   = undef,
  Optional[String] $sa_pub               = undef,
  Optional[String] $sa_key               = undef,

  Eit_types::Encrypt::Params $encrypt_params = [
    'etcd_ca_key',
    'kubernetes_ca_key',
    'front_proxy_ca_key',
    'sa_key',
  ]
) {
}
