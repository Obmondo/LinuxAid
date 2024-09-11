# Ubuntu and Debian Upstream APT repos
class eit_repos::apt::upstream (
  Boolean           $ensure     = true,
  Optional[Boolean] $noop_value = $eit_repos::noop_value,
) {

  $distro = $facts['os']['distro']['codename']

  # Get the architecture
  $architecture = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    default   => 'amd64',
  }

  # Get the location
  $location = $architecture ? {
    'arm64' => 'http://ports.ubuntu.com/ubuntu-ports',
    default => 'http://archive.ubuntu.com/ubuntu',
  }

  $source = $architecture ? {
    'arm64' => 'http://ports.ubuntu.com/ubuntu-ports/project/ubuntu-archive-keyring.gpg',
    default => 'http://archive.ubuntu.com/ubuntu/project/ubuntu-archive-keyring.gpg',
  }

  case $facts['os']['distro']['id'] {
    'Ubuntu': {
      $repos = [$distro, "${distro}-updates", "${distro}-security"]

      $repos.each |$_repos| {
        apt::source { "ubuntu-${_repos}":
          ensure       => ensure_present($ensure),
          location     => $location,
          noop         => $noop_value,
          architecture => $architecture,
          release      => $_repos,
          repos        => 'main universe multiverse restricted',
          key          => {
            'id'     => '630239CC130E1A7FD81A27B140976EAF437D05B5',
            'source' => $source,
          },
        }
      }
    }
    'Debian': {
      $repos = {
        "${distro}"          => 'https://deb.debian.org/debian',
        "${distro}-updates"  => 'https://deb.debian.org/debian',
        "${distro}-security" => 'https://security.debian.org',
      }

      $repos.each |$key, $value | {
        apt::source { $key :
          ensure   => ensure_present($ensure),
          location => $value,
          noop     => $noop_value,
          release  => $key,
          repos    => 'main contrib non-free',
        }
      }

      $apt_keys = {
        'AC530D520F2F3269F5E98313A48449044AAD5C5D' => "https://deb.debian.org/debian/dists/${distro}/Release.gpg",
        '1F89983E0081FDE018F3CC9673A4F27B8DD47936' => "https://security.debian.org/dists/${distro}-security/Release.gpg",
      }

      $apt_keys.each | $key, $value | {
        apt::key { $key :
          ensure => ensure_present($ensure),
          id     => $key,
          noop   => $noop_value,
          source => $value,
        }
      }
    }
    default: {
      fail("This ${distro} is not supported for upstream repos")
    }
  }

}
