# @summary
#  Class configures files and directories for wireguard
# @param config_dir
#   Path to wireguard configuration files
# @param config_dir_mode
#   The config_dir access mode bits
class wireguard::config (
  Stdlib::Absolutepath $config_dir,
  String               $config_dir_mode,
) {

  file {$config_dir:
    ensure => 'directory',
    mode   => $config_dir_mode,
    owner  => 'root',
    group  => 'root',
  }
}
