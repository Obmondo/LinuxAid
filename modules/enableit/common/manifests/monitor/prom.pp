# Prometheus Server
# setup these resources in noop mode
# and we dont allow anyone to change the noop setting
class common::monitor::prom (
  Boolean[false]       $noop_value,
  Enum['package']      $install_method,
  Stdlib::Absolutepath $env_file_path,
  Stdlib::Absolutepath $bin_dir,
  Stdlib::Absolutepath $usershell,
) {
  File {
    noop => $noop_value
  }

  Service {
    noop => $noop_value
  }

  Package {
    noop => $noop_value
  }

  User {
    noop => $noop_value
  }

  Group {
    noop => $noop_value
  }

  # The prometheus upstream module does not have the support for env_file_path on suse os family.
  # will rase the PR for that

  class { 'prometheus' :
    install_method    => $install_method,
    bin_dir           => $bin_dir,
    usershell         => $usershell,
    restart_on_change => true,
    env_file_path     => $env_file_path,
  }
}
