# Sudoers
class profile::system::sudoers (
  Boolean              $purge         = $common::system::authentication::sudo::purge,
  Eit_types::Sudoers   $sudoers       = $common::system::authentication::sudo::sudoers,
  Stdlib::Absolutepath $sudoers_d_dir = $common::system::authentication::sudo::__sudoers_d_dir,
) {

  contain sudo::params

  # Setup the directory
  file { $sudoers_d_dir :
    ensure  => directory,
    purge   => true,
    recurse => true,
    noop    => false,
    before  => Class['sudo'],
  }

  # Some files in sudoers have wrong permissions, which can cause the execution
  # of `visudo -c` to fail. If this happens then sudoers rules won't be
  # installed, even if they're perfectly valid and the error only happens
  # because of a file provided with the OS.
  exec { 'fix permissions on sudoers files':
    command => 'chmod a=,ug=r /etc/sudoers.d/*',
    path    => '/usr/bin:/bin',
    unless  => 'find /etc/sudoers.d/ -maxdepth 1 -type f -not -perm ug=r -exec false {} \+',
    # This has to run as noop => false, otherwise we can't install any sudo
    # rules necessary for monitoring
    noop    => false,
    before  => Class['sudo'],
  }

  $_sudoedit_paths = [
    '/bin/sudoedit',
    '/usr/bin/sudoedit',
    ]

  Package {
    noop   => false,
    notify => File[$_sudoedit_paths],
  }

  class { 'sudo':
    # This needs to end in a trailing slash because of the upstream module
    # config_dir          => "${sudoers_d_dir}/",
    config_file_replace => true,
    purge               => $purge,
    require             => File[$sudoers_d_dir],
  }

  # Mitigation for CVE-2021-3156: Baron Samedit: Heap-based buffer overflow in
  # Sudo
  file { $_sudoedit_paths:
    ensure => absent,
    noop   => false,
  }

  Sudo::Conf {
    sudo_config_dir => "${sudoers_d_dir}/",
    require         => File[$sudoers_d_dir],
  }

  sudo::conf { 'yubikey_sudo_enable':
    ensure   => $common::system::authentication::sudo::ssh_agent_auth,
    priority => 1,
    content  => 'Defaults env_keep += "SSH_AUTH_SOCK"',
    require  => File[$sudoers_d_dir],
  }

  package::install('pam-ssh-agent-auth', $common::system::authentication::sudo::ssh_agent_auth)

  $sudoers.each |$name, $v| {
    profile::system::sudoers::conf { $name:
      * => $v,
    }
  }

  $_sudoers_include_obmondo_name = 'sudoers include obmondo'
  sudo::conf { $_sudoers_include_obmondo_name:
    content         => "#includedir ${sudoers_d_dir}",
    sudo_config_dir => $sudo::params::config_dir,
    priority        => 999,
  }

  File <| title == "999_${_sudoers_include_obmondo_name.regsubst('\.', '-', 'G')}" |> {
    noop => false,
  }
}
