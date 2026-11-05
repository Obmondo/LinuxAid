# Ubuntu and Debian Upstream APT repos
#
# @param ensure Whether the upstream repos are present.
#
# @param proposed Ubuntu only: also add the <codename>-proposed pocket. Ubuntu marks it
#   NotAutomatic, so apt installs nothing from it unless a package is listed in
#   proposed_packages.
#
# @param proposed_packages Packages (apt globs allowed, e.g. 'linux-*') that may come from
#   -proposed. They are pinned to priority 500 there, so a normal upgrade picks a newer
#   version from -proposed, e.g. a security fix that is only in -proposed so far.
#
# @param noop_value Noop for the managed resources.
#
class eit_repos::apt::upstream (
  Boolean               $ensure            = true,
  Boolean               $proposed          = false,
  Array[String[1]]      $proposed_packages = [],
  Eit_types::Noop_Value $noop_value        = undef,
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

      $_proposed_repo = $proposed ? {
        true    => ["${distro}-proposed"],
        default => [],
      }

      $repos = [$distro, "${distro}-updates", "${distro}-security"] + $_proposed_repo

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

      if $proposed and !$proposed_packages.empty {
        apt::pin { 'ubuntu-proposed':
          ensure   => ensure_present($ensure),
          packages => $proposed_packages,
          release  => "${distro}-proposed",
          priority => 500,
          noop     => $noop_value,
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
