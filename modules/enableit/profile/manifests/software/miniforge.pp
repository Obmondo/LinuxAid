# Miniforge3 Setup
#
# @summary Class for managing the Miniforge software
#
# @param manage Boolean parameter to control management of Miniforge.
#
# @param enable Boolean parameter to control whether Miniforge is installed or not.
#
# @param version Eit_types::Version parameter to control version of Miniforge3.
#
# @param install_dir Stdlib::Absolutepath parameter to control installation directory of Miniforge3.
#
class profile::software::miniforge (
  Boolean              $manage      = $common::software::miniforge::manage,
  Boolean              $enable      = $common::software::miniforge::enable,
  Eit_types::Version   $version     = $common::software::miniforge::version,
  Stdlib::Absolutepath $install_dir = $common::software::miniforge::install_dir,
){

  $package_url   = "https://github.com/conda-forge/miniforge/releases/download/${version}/Miniforge3-${version}-Linux-x86_64.sh"
  $package_name  = "Miniforge-${version}-Linux-x86_64.sh"
  $download_path = "/tmp/${package_name}"

  # Download the installer script
  archive { $download_path:
    ensure  => ensure_present($enable),
    source  => $package_url,
    extract => false,
    cleanup => false,
  }

  # Oneshot service for installing Miniforge.
  systemd::manage_unit { 'miniforge_install.service':
    ensure     => ensure_present($enable),
    enable     => false,
    unit_entry => {
      'Description' => 'Miniforge Install Service',
    },
    service_entry => {
      'Type'            => 'oneshot',
      'ExecStart'       => "${download_path} -b -p ${install_dir}",
      'RemainAfterExit' => true,
    },
    install_entry => {
      'WantedBy' => 'multi-user.target',
    },
    require => Archive[$download_path],
  }
}
