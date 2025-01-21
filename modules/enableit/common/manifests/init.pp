# Main common class
class common (
  Boolean $full_host_management = true,
  Hash    $devices              = {},
  Hash[Stdlib::Absolutepath,
    Tuple[
      Eit_types::Mount,
      [
        Variant[
          Eit_types::MountLuks,
          Eit_types::MountNfs,
        ]
      ],
    ]
  ] $mounts = {},
  Hash[Stdlib::Absolutepath,
    Struct[
      {
      mode => Stdlib::Filemode,
      apply_recursively => Boolean,
      }]] $filepermissions = {},
) {
  Exec { path => ['/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin'] }

  Stage['setup'] -> Stage['main']

  $_full_host_management = if 'role::monitoring' in $facts['obmondo_classes'] {
    false
  } else {
    $full_host_management
  }

  if $::obmondo_monitoring_status {
    # NOTE: Lets not allow anyone to remove our public repo, otherwise monitoring won't be setup
    eit_repos::repo { 'enableit_client':
      noop_value => false,
    }

    # NOTE: Need these classes to be setup as a bare minimum on all roles
    # These classes are loaded on each puppet run, and will be setup in noop
    contain ::common::setup
    contain ::common::puppet
    contain ::common::monitor
    contain ::common::monitoring
    contain ::common::hosts

    # NOTE: when user only want role::basic and repo + updates with no full host management
    if 'role::basic' in $facts['obmondo_classes'] and !$_full_host_management {
      contain ::common::repo
      contain ::common::certs
      contain ::common::system::updates
    }

    # NOTE: full_host_management defaults to true, except for role::monitoring
    # If you need these classes, then one has to enable full_host_management
    if $_full_host_management {
      contain ::common::logging
      contain ::common::backup
      contain ::common::cron
      contain ::common::convenience
      contain ::common::repo
      contain ::common::certs
      contain ::common::package
      contain ::common::system
      contain ::common::software
      contain ::common::devices
      contain ::common::virtualization
      contain ::common::storage
      contain ::common::lvm
      contain ::common::network

      # TODO: common::mount is not used anywhere
      # but keeping, so we can enable or improve it later
      # contain ::common::mount
      contain ::common::services
      contain ::common::security
      contain ::common::extras

      # Only manage mail if not using a role that provides it
      if $facts['obmondo_classes'].grep('::kolab').empty or $facts['obmondo_classes'].grep('::mailcow').empty {
        contain ::common::mail
      }

      $filepermissions.each |$path, $params| {
        $recurse = if $params[apply_recursively] { '-r' } else { '' }
        $mode = $params[mode]
        exec { "chmod ${recurse} ${mode} ${path}":
          onlyif => "stat ${path}",
          unless => "stat /tmp --format=%a | grep -E ${mode}",
          noop   => false,
        }
      }
    }
  }
}
