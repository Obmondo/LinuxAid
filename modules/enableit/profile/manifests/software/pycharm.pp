# Pycharm Setup
# @summary Class for managing the PyCharm software
#
# @param enable Boolean parameter to enable or disable PyCharm. Defaults to true.
#
# @param version String parameter to control version of PyCharm.
#
# @param noop_value Optional boolean to specify noop mode value.
#
class profile::software::pycharm (
  Boolean               $enable     = $common::software::pycharm::enable,
  Eit_types::Version    $version    = $common::software::pycharm::version,
  Eit_types::Noop_Value $noop_value = $common::software::pycharm::noop_value,
){

  $package_url   = "https://download-cdn.jetbrains.com/python/pycharm-${version}.tar.gz"
  $package_name  = "pycharm-${version}.tar.gz"
  $download_path = "/tmp/${package_name}"
  $install_dir   = "/opt/pycharm-${version}"
  $symlink_path  = '/usr/local/bin/pycharm'

  Archive {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  # Download and extract PyCharm
  archive { $download_path:
    ensure       => ensure_present($enable),
    source       => $package_url,
    extract      => true,
    extract_path => '/opt/',
    creates      => $install_dir,
    cleanup      => true,
  }

  # Create a symlink to make 'pycharm' command available
  file { $symlink_path:
    ensure  => ensure_present($enable),
    target  => "${install_dir}/bin/pycharm.sh",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Archive[$download_path],
  }
}
