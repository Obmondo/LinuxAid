# @summary
#  Class that contains OS specific parameters for other classes
class wireguard::params {
  $config_dir_mode    = '0700'
  case $facts['os']['name'] {
    'RedHat', 'CentOS', 'VirtuozzoLinux': {
      $manage_package = true
      $manage_repo    = true
      $package_name   = ['wireguard-dkms', 'wireguard-tools']
      $repo_url       = 'https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo'
      $config_dir     = '/etc/wireguard'
    }
    'Ubuntu': {
      $manage_package = true
      $manage_repo    = true
      $package_name   = ['wireguard', 'wireguard-dkms', 'wireguard-tools']
      $repo_url       = 'ppa:wireguard/wireguard'
      $config_dir     = '/etc/wireguard'
    }
    'Debian': {
      $manage_package = true
      $manage_repo    = true
      $package_name   = ['wireguard', 'wireguard-dkms', 'wireguard-tools']
      $repo_url       = 'http://deb.debian.org/debian/'
      $config_dir     = '/etc/wireguard'
    }
    default: {
      warning("Unsupported OS family, couldn't configure package automatically")
    }
  }
}
