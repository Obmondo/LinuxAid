# @summary Class for managing Prometheus server monitoring configuration
#
# @param noop_value
# Whether to run resources in noop mode. Defaults to false.
#
# @param install_method The installation method to use. Defaults to 'package'.
#
# @param env_file_path The absolute path to the environment file.
#
# @param bin_dir The absolute path to the binary directory.
#
# @param usershell The absolute path to the user's shell.
#
# @param server The HTTPS url for prometheus URL. Must be a Stdlib::FQDN
#
class common::monitor::prometheus (
  Enum['package']      $install_method,
  Stdlib::Absolutepath $env_file_path,
  Stdlib::Absolutepath $bin_dir,
  Stdlib::Absolutepath $usershell,
  Stdlib::Fqdn         $server,

  Boolean              $noop_value = false,
) {
  File {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  Package {
    noop => $noop_value,
  }

  User {
    noop => $noop_value,
  }

  Group {
    noop => $noop_value,
  }

  $_init_style = $facts['init_system'] ? {
    'sysvinit' => 'sysv',
    'default' => 'systemd',
  }

  class { 'prometheus':
    install_method    => $install_method,
    bin_dir           => $bin_dir,
    usershell         => $usershell,
    restart_on_change => true,
    env_file_path     => $env_file_path,
    init_style        => $_init_style,
  }
}
