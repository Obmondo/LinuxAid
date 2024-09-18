# Ubuntu and Debian Upstream APT repos
class eit_repos::apt::upstream (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  $distro = $facts['os']['distro']['codename']
  $_os_type = downcase($facts['os']['distro']['id'])

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  case $facts['os']['distro']['id'] {
    'Ubuntu': {
      # Get the location
      $location = $architecture ? {
        'arm64' => 'http://ports.ubuntu.com/ubuntu-ports',
        default => 'http://archive.ubuntu.com/ubuntu',
      }

      $repos = [$distro, "${distro}-updates", "${distro}-security"]

      $repos.each |$_repo| {
        apt::source { "ubuntu-${_repo}":
          ensure       => ensure_present($ensure),
          location     => $location,
          noop         => $noop_value,
          architecture => $architecture,
          release      => $_repo,
          repos        => 'main universe multiverse restricted',
          keyring      => "/usr/share/keyrings/${_os_type}-archive-keyring.gpg",
        }
      }
    }
    'Debian': {
      $distro_repos = {
        "${distro}"          => 'https://deb.debian.org/debian',
        "${distro}-updates"  => 'https://deb.debian.org/debian',
        "${distro}-security" => 'https://security.debian.org',
      }

      $distro_repos.each |$key, $value | {
        apt::source { $key:
          ensure       => ensure_present($ensure),
          location     => $value,
          noop         => $noop_value,
          architecture => $architecture,
          release      => $key,
          repos        => 'main contrib non-free',
          keyring      => "/usr/share/keyrings/${_os_type}-archive-keyring.gpg",
        }
      }
    }
    default: {
      fail("This ${distro} is not supported for upstream repos")
    }
  }

}
