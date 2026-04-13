# @summary Class for managing the Miniforge software
#
# @param manage Boolean parameter to control management of Miniforge. Defaults to false.
#
# @param enable Boolean parameter to control whether Miniforge is installed or not. Defaults to true.
#
# @param version Eit_types::Version parameter to control version of Miniforge3.
#
# @param install_dir Stdlib::Absolutepath parameter to control installation directory of Miniforge3.
#
# @param conda_forge_packages Array of conda-forge package names to install (e.g. ['exec-wrappers']).
#
# @groups management manage, enable.
#
# @groups installation version, install_dir, conda_forge_packages.
#
class common::software::miniforge (
  Boolean              $manage               = false,
  Boolean              $enable               = true,
  Eit_types::Version   $version              = '25.9.1-0',
  Stdlib::Absolutepath $install_dir          = '/opt/miniforge',
  Array[String[1]]     $conda_forge_packages = [],
) {

  if $manage {
    contain profile::software::miniforge
  }
}
