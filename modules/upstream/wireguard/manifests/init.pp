# @summary
#   Wireguard class manages wireguard - an open-source software application
#   and protocol that implements virtual private network techniques to create
#   secure point-to-point connections in routed or bridged configurations.
# @see https://www.wireguard.com/
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
# @param config_dir
#   Path to wireguard configuration files
# @param config_dir_mode
#   The config_dir access mode bits
# @param interfaces
#   Define wireguard interfaces
class wireguard (
  Variant[Array, String] $package_name    = $wireguard::params::package_name,
  String                 $repo_url        = $wireguard::params::repo_url,
  Boolean                $manage_repo     = $wireguard::params::manage_repo,
  Boolean                $manage_package  = $wireguard::params::manage_package,
  Variant[Boolean, Enum['installed','latest','present']] $package_ensure = 'installed',
  Stdlib::Absolutepath   $config_dir      = $wireguard::params::config_dir,
  String                 $config_dir_mode = $wireguard::params::config_dir_mode,
  Optional[Hash]         $interfaces      = {},
) inherits wireguard::params {

  class { 'wireguard::install':
    package_name   => $package_name,
    package_ensure => $package_ensure,
    repo_url       => $repo_url,
    manage_repo    => $manage_repo,
    manage_package => $manage_package,
  }
  -> class { 'wireguard::config':
    config_dir      => $config_dir,
    config_dir_mode => $config_dir_mode,
  }
  -> Class[wireguard]

  $interfaces.each |$name, $options| {
    wireguard::interface { $name:
      * => $options,
    }
  }
}
