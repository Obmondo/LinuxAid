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
class common::software::miniforge (
  Boolean              $manage      = false,
  Boolean              $enable      = true,
  Eit_types::Version   $version     = '25.9.1-0',
  Stdlib::Absolutepath $install_dir = '/opt/miniforge',
) {

  if $manage {
    contain profile::software::miniforge
  }
}
