# Kubernetes
# NOTE: kubernetes apt repository only has packages for xenial
# Kubernetes only works with xenial, but those xenial packages works fine on focal
class profile::virtualization::kubernetes (
  Enum['controller','worker'] $role                       = $::role::virtualization::kubernetes::role,
  Optional[String]            $etcd_ca_crt                = $::role::virtualization::kubernetes::etcd_ca_crt,
  Optional[String] $etcd_ca_key                           = $::role::virtualization::kubernetes::etcd_ca_key,
  Optional[String]            $etcdclient_crt             = $::role::virtualization::kubernetes::etcdclient_crt,
  Optional[String] $etcdclient_key                        = $::role::virtualization::kubernetes::etcdclient_key,
  Optional[String]            $etcdserver_crt             = $::role::virtualization::kubernetes::etcdserver_crt,
  Optional[String] $etcdserver_key                        = $::role::virtualization::kubernetes::etcdserver_key,
  Optional[String]            $etcdpeer_crt               = $::role::virtualization::kubernetes::etcdpeer_crt,
  Optional[String] $etcdpeer_key                          = $::role::virtualization::kubernetes::etcdpeer_key,
  Optional[String]            $kubernetes_ca_crt          = $::role::virtualization::kubernetes::kubernetes_ca_crt,
  Optional[String] $kubernetes_ca_key                     = $::role::virtualization::kubernetes::kubernetes_ca_key,
  String           $discovery_token_hash                  = $::role::virtualization::kubernetes::discovery_token_hash,
  Optional[String]            $front_proxy_ca_crt         = $::role::virtualization::kubernetes::front_proxy_ca_crt,
  Optional[String] $front_proxy_ca_key                    = $::role::virtualization::kubernetes::front_proxy_ca_key,
  Optional[String]            $sa_pub                     = $::role::virtualization::kubernetes::sa_pub,
  Optional[String] $sa_key                                = $::role::virtualization::kubernetes::sa_key,
  String           $token                                 = $::role::virtualization::kubernetes::token,
  Optional[Array]             $apiserver_cert_extra_sans  = $::role::virtualization::kubernetes::apiserver_cert_extra_sans,
  Eit_types::IPPort           $controller_address         = $::role::virtualization::kubernetes::controller_address,
  Optional[String]            $etcd_initial_cluster       = $::role::virtualization::kubernetes::etcd_initial_cluster,
  Array                       $etcd_peers                 = $::role::virtualization::kubernetes::etcd_peers,
  Optional[Array]             $worker_peers               = $::role::virtualization::kubernetes::worker_peers,
  String                      $version                    = $::role::virtualization::kubernetes::version,
  Eit_types::IPCIDR           $pod_cidr                   = $::role::virtualization::kubernetes::pod_cidr,
  Boolean                     $install_dashboard          = $::role::virtualization::kubernetes::install_dashboard,
  Optional[Array[Variant[
    Stdlib::IP::Address,
    Stdlib::Host
  ]]]                         $allow_k8s_api              = $::role::virtualization::kubernetes::allow_k8s_api,
  Boolean                     $expose_https_on_master     = $::role::virtualization::kubernetes::expose_https_on_master,
  Boolean                     $expose_http_on_master      = $::role::virtualization::kubernetes::expose_http_on_master,
  Optional[Stdlib::Fqdn]      $keycloak_oidc_domain       = $::role::virtualization::kubernetes::keycloak_oidc_domain,
  String                      $keycloak_oidc_client_id    = $::role::virtualization::kubernetes::keycloak_oidc_client_id,
  Boolean                     $keycloak_oidc_groups_claim = $::role::virtualization::kubernetes::keycloak_oidc_groups_claim,
  Array[Stdlib::Port]         $extra_public_ports         = $::role::virtualization::kubernetes::extra_public_ports,
  Optional[String]            $docker_storage_driver      = $::role::virtualization::kubernetes::docker_storage_driver,
  Optional[String]            $containerd_version         = $::role::virtualization::kubernetes::containerd_version,
  Optional[String]            $image_repository           = $::role::virtualization::kubernetes::image_repository,
  Optional[String]            $containerd_config_template = $::role::virtualization::kubernetes::containerd_config_template,
  Optional[String]            $containerd_install_method  = $::role::virtualization::kubernetes::containerd_install_method,
  Enum['overlayfs', 'zfs']    $containerd_snapshotter     = $::role::virtualization::kubernetes::containerd_snapshotter,
) {

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

    file { '/root/.kube':
        ensure => directory,
        mode   => '0750',
    }
    file { '/root/.kube/config':
      ensure  => present,
      source  => '/etc/kubernetes/admin.conf',
      require => [File['/root/.kube'],Class['kubernetes']],
    }
  }

  # Allow etcd_peers and range of IPs to access k8s api
  firewall_multi { '010 allow access to k8s api from worker and master nodes':
    proto  => 'all',
    jump   => 'accept',
    source => [$etcd_peers + $worker_peers].flatten.delete_undef_values,
  }

  # Allow etcd_peers and range of IPs to access k8s api
  if !empty($allow_k8s_api) {
    firewall_multi { '010 allow access to k8s api':
      proto  => 'tcp',
      dport  => '6443',
      jump   => 'accept',
      source => $allow_k8s_api,
    }
  }

  # Allow ssh using teleport
  if !empty($extra_public_ports) {

    firewall_multi { '010 allow access though teleport':
      proto => 'tcp',
      dport => $extra_public_ports,
      jump  => 'accept',
    }
  }

  # Expose http and https
  firewall_multi { '010 allow access to k8s http':
    proto => 'tcp',
    dport => [
      if $expose_http_on_master { '80' },
      if $expose_https_on_master { '443' },
    ],
    jump  => 'accept',
  }

  package { 'cri-tools':
    ensure => present,
  }

  # https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
  file { '/etc/kubernetes/tigera-operator.yaml':
    ensure => present,
    source => 'puppet:///modules/customers/virtualization/kubernetes/tigera-operator.yaml',
  }

  # NOTE: kubernetes puppet module has a bug
  # Which adds the config in `/etc/kubernetes/config.yaml` rather then `/etc/kubernetes/manifests/kube-apiserver.yaml`
  # https://github.com/puppetlabs/puppetlabs-kubernetes/issues/445
  $_apiserver_extra_args = if $keycloak_oidc_domain {
    [
      # NOTE: we assume, the default master realm is what we will be using.
      if $keycloak_oidc_domain { "--oidc-issuer-url=https://${keycloak_oidc_domain}/auth/realms/master" },
      if $keycloak_oidc_client_id { "--oidc-client-id=${keycloak_oidc_client_id}" },
      if $keycloak_oidc_groups_claim { '--oidc-groups-claim=groups' }
    ].delete_undef_values
  }

  $k8s_major_version = regsubst($version, '^(\d+)\.(\d+)\.(\d+)', '\1.\2')

  # NOTE
  # curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  # apt module does not support new gpg format
  # so have ran this manually, there is an upstream PR for this
  # https://github.com/puppetlabs/puppetlabs-kubernetes/pull/657
  class { 'kubernetes' :
    controller                    => if $role == 'controller' { true },
    worker                        => if $role == 'worker' { true },
    manage_docker                 => false,
    pin_packages                  => true,
    cgroup_driver                 => 'systemd',
    # pointing it to 3.3.0 since specs were written till this version of etcd
    etcd_version                  => '3.3.0',
    etcd_peers                    => $etcd_peers,
    etcd_initial_cluster          => $etcd_initial_cluster,
    schedule_on_controller        => true,
    kubernetes_version            => $version,
    kubernetes_package_version    => "${version}-1.1",
    container_runtime             => 'cri_containerd',
    cni_pod_cidr                  => $pod_cidr,
    cni_network_provider          => 'puppet:///modules/customers/virtualization/kubernetes/custom-resources.yaml',
    cni_provider                  => 'calico-tigera',
    cni_network_preinstall        => '/etc/kubernetes/tigera-operator.yaml',
    etcd_ip                       => $facts.dig('networking', 'ip'),
    kube_api_advertise_address    => $facts.dig('networking', 'ip'),
    kubernetes_apt_location       => "https://pkgs.k8s.io/core:/stable:/v${k8s_major_version}/deb/",
    kubernetes_apt_repos          => '/',
    kubernetes_apt_release        => ' ',
    kubernetes_key_source         => "https://pkgs.k8s.io/core:/stable:/v${k8s_major_version}/deb/Release.key",
    api_server_count              => $etcd_peers.size,
    controller_address            => $controller_address,
    token                         => $token.node_encrypt::secret,
    etcd_hostname                 => $facts.dig('fqdn'),
    etcd_ca_crt                   => $etcd_ca_crt,
    etcd_ca_key                   => $etcd_ca_key.node_encrypt::secret,
    etcdclient_crt                => $etcdclient_crt.node_encrypt::secret,
    etcdclient_key                => $etcdclient_key.node_encrypt::secret,
    etcdserver_crt                => $etcdserver_crt,
    etcdserver_key                => $etcdserver_key.node_encrypt::secret,
    etcdpeer_crt                  => $etcdpeer_crt,
    etcdpeer_key                  => $etcdpeer_key.node_encrypt::secret,
    kubernetes_ca_crt             => $kubernetes_ca_crt,
    kubernetes_ca_key             => $kubernetes_ca_key.node_encrypt::secret,
    discovery_token_hash          => $discovery_token_hash.node_encrypt::secret,
    kubernetes_front_proxy_ca_crt => $front_proxy_ca_crt,
    kubernetes_front_proxy_ca_key => $front_proxy_ca_key.node_encrypt::secret,
    sa_pub                        => $sa_pub,
    sa_key                        => $sa_key.node_encrypt::secret,
    apiserver_cert_extra_sans     => $apiserver_cert_extra_sans,
    install_dashboard             => $install_dashboard,
    node_label                    => $facts.dig('fqdn'),
    containerd_version            => $containerd_version,
    image_repository              => $image_repository,
    containerd_config_template    => $containerd_config_template,
    containerd_install_method     => $containerd_install_method,
    containerd_snapshotter        => $containerd_snapshotter,
  }
}
