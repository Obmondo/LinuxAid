# Rackslab Slurm-web APT repos
class eit_repos::apt::rackslab_slurmweb (
  Boolean $ensure     = true,
  Boolean $noop_value = $eit_repos::noop_value,
) {

  $distro = $facts['os']['distro']['release']
  $release = $facts['os']['distro']['release']['full']

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  if $facts['os']['distro']['id'] == 'Ubuntu' {
    apt::source { 'rackslab-slurmweb':
      ensure       => ensure_present($ensure),
      location     => "https://pkgs.rackslab.io/deb/ubuntu${release}",
      noop         => $noop_value,
      architecture => $architecture,
      release      => $distro,
      repos        => 'slurmweb-5',
      key          => {
        name   => 'rackslab-slurmweb.asc',
        source => 'puppet:///modules/eit_repos/apt/rackslab-slurmweb.gpg',
      },
    }
  }
}
