# @summary
#  Class installs wireguard packages and sets yum repository
# @param package_name
#   Name the package(s) that installs wireguard
# @param repo_url
#   URL of wireguard repo
# @param manage_repo
#   Should class manage yum repo
# @param manage_package
#   Should class install package(s)
# @param package_ensure
#   Set state of the package
class wireguard::install (
  Variant[Array, String] $package_name,
  String                 $repo_url,
  Boolean                $manage_repo,
  Boolean                $manage_package,
  Variant[Boolean, Enum['installed','latest','present']] $package_ensure,
) {

  if $manage_repo {
    case $facts['os']['name'] {
      'RedHat', 'CentOS': {
        exec {'download_wireguard_repo':
          command => "/usr/bin/curl -Lo /etc/yum.repos.d/wireguard.repo ${repo_url}",
          creates => '/etc/yum.repos.d/wireguard.repo',
        }
      }
      'Ubuntu': {
        include apt
      }
      'Debian': {
        include apt
        apt::pin { 'debian_unstable':
          release  => 'unstable',
          priority => 90,
        }
        apt::source { 'debian_unstable':
          location => $repo_url,
          release  => 'unstable',
        }
      }
      default: {
        warning("Unsupported OS family, couldn't configure package automatically")
      }
    }
  }

  case $facts['os']['name'] {
    'RedHat', 'CentOS': {
      $_require = $manage_repo ? {
        true    => Exec['download_wireguard_repo'],
        default => undef,
      }
    }
    'Ubuntu': {
      $_require = $manage_repo ? {
        default => undef,
      }
    }
    'Debian': {
      $_require = $manage_repo ? {
        true    => Apt::Source['debian_unstable'],
        default => undef,
      }
    }
    default: {
      if $manage_package {
        warning("Unsupported OS family, couldn't configure package automatically")
      }
    }
  }

  if $manage_package {
    package { $package_name:
      ensure  => $package_ensure,
      require => $_require,
    }
  }
}
