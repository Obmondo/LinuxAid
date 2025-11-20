# Docker APT repos
class eit_repos::apt::docker (
  Boolean               $ensure     = true,
  Eit_types::Noop_Value $noop_value = $eit_repos::noop_value,
) {

  $distro = $facts['os']['distro']['codename']

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  if $facts['os']['distro']['id'] == 'Ubuntu' {
    apt::source { 'docker-ce-stable':
      ensure       => ensure_present($ensure),
      location     => 'https://download.docker.com/linux/ubuntu',
      noop         => $noop_value,
      architecture => $architecture,
      release      => $distro,
      repos        => 'stable',
      key          => {
        name   => "docker_${distro}.asc",
        source => 'https://download.docker.com/linux/ubuntu/gpg',
      },
    }
  }
}
