# Kubernetes APT repos
class eit_repos::apt::kubernetes (
  Boolean               $ensure     = true,
  Array[String]         $versions   = ['v1.27'],
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $versions.each |$version| {
    apt::source { "kubernetes_${version}":
      ensure       => ensure_present($ensure),
      location     => "https://pkgs.k8s.io/core:/stable:/${version}/deb/ /",
      noop         => $noop_value,
      architecture => 'amd64',
      # NOTE: empty string is on purpose, since all k8s package works for all distros
      release      => '',
      repos        => '',
      key          => {
        'name'   => "kubernetes_${version}.gpg",
        'source' => 'puppet:///modules/eit_repos/apt/kubernetes-apt-keyring.gpg',
      },
    }
  }
}
