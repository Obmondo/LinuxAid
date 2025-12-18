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
  Enum['package','url'] $install_method,
  Prometheus::Initstyle $init_style,
  Stdlib::Absolutepath  $env_file_path,
  Stdlib::Absolutepath  $bin_dir,
  Stdlib::Absolutepath  $usershell,
  Stdlib::Fqdn          $server,
  Eit_types::Noop_Value $noop_value = $common::monitor::noop_value,
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

  class { 'prometheus':
    install_method    => $install_method,
    bin_dir           => $bin_dir,
    usershell         => $usershell,
    restart_on_change => true,
    env_file_path     => $env_file_path,
    init_style        => $init_style,
  }

  include common::monitor::prometheus::server
  include common::monitor::exporter
}
