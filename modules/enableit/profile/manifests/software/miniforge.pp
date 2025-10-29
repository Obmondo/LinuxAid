# Miniforge3 Setup
# @summary Class for managing the Miniforge software
#
# @param enable Boolean parameter to enable or disable Miniforge. Defaults to true.
#
# @param version String parameter to control version of Miniforge3.
#
# @param noop_value Optional boolean to specify noop mode value.
#
class profile::software::miniforge (
  Boolean           $enable     = $common::software::miniforge::enable,
  String            $version    = $common::software::miniforge::version,
  Optional[Boolean] $noop_value = $common::software::miniforge::noop_value,
){

  $package_url   = "https://github.com/conda-forge/miniforge/releases/download/${version}/Miniforge3-${version}-Linux-x86_64.sh"
  $install_dir   = "/opt/miniforge"
  $package_name  = "Miniforge-${version}-Linux-x86_64.sh"
  $download_path = "/tmp/${package_name}"

  Archive {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  # Download the installer script
  archive { $download_path:
    ensure       => ensure_present($enable),
    source       => $package_url,
    extract      => false,
    creates      => $download_path,
    cleanup      => false,
  }

  # Onshot service for instaling Miniforge.
  common::services::systemd { 'miniforge_install.service':
    ensure  => ensure_service($enable),
    enable  => false,
    unit    => {
      'Description' => 'Miniforge Install Service',
    },
    service => {
      'Type'            => 'oneshot',
      'ExecStart'       => "/usr/bin/bash ${download_path} -b -p ${install_dir}",
      'RemainAfterExit' => 'yes',
    },
    install => {
      'WantedBy' => 'multi-user.target',
    },
    require    => Archive[$download_path],
  }
}
