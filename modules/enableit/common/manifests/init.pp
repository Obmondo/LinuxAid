# @summary Main common class
#
# @param full_host_management Boolean to enable or disable full host management functionalities. Defaults to true.
#
# @param devices Hash containing device configurations. Defaults to an empty hash.
#
# @param mounts Hash mapping absolute paths to mount points and their types. Defaults to an empty hash.
#
# @param filepermissions Hash specifying file permission settings.
#
class common (
  Boolean $full_host_management,
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
  # lint:ignore:top_scope_facts
  if $::obmondo_monitoring_status {
    # NOTE: Lets not allow anyone to remove our public repo, otherwise monitoring won't be setup
    # NOTE: For now, ignore setting up monitoring for TurrisOS, since opkg isn't supported as package provider.
    # NOTE: Later this needs to be fixed.
    if $facts['os']['name'] != 'TurrisOS' {
      eit_repos::repo { 'enableit_client':
          noop_value => false,
      }
    }

    # NOTE: Need these classes to be setup as a bare minimum on all roles
    # These classes are loaded on each puppet run, and will be setup in noop
    lookup('common::default::classes').each | $role | {
      contain $role
    }
    # NOTE: when user only want role::basic and repo + updates with no full host management
    if 'role::basic' in $::obmondo_classes and !$full_host_management {
      lookup('common::role_basic::classes').each | $role | {
        contain $role
      }
    }
    # NOTE: full_host_management defaults to true, except for role::monitoring
    # If you need these classes, then one has to enable full_host_management
    if $full_host_management {
      contain common::logging
      contain common::backup
      contain common::cron
      contain common::convenience
      contain common::repo
      contain common::certs
      contain common::package
      contain common::system
      contain common::software
      contain common::devices
      contain common::virtualization
      contain common::storage
      contain common::lvm
      contain common::network
      # TODO: common::mount is not used anywhere
      # but keeping, so we can enable or improve it later
      # contain ::common::mount
      contain common::services
      contain common::security
      contain common::extras
      # Only manage mail if not using a role that provides it
      if $::obmondo_classes.grep('::mailcow').empty {
        contain common::mail
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
