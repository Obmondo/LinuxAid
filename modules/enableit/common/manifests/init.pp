# @summary Main common class
#
# @param full_host_management Boolean to enable or disable full host management functionalities. Defaults to true.
#
# @param noop_value Noop value for the common class. Defaults to undef.
#
# @groups management full_host_management
#
# @groups configuration noop_value
#
class common (
  Boolean               $full_host_management,
  Eit_types::Noop_Value $noop_value = undef,
  Stdlib::Absolutepath  $__conf_dir = '/etc/obmondo',
  Stdlib::Absolutepath  $__opt_dir  = '/opt/obmondo',
  Stdlib::Absolutepath  $__bin_dir  = '/opt/obmondo/bin',
) {
  Exec { path => ['/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin'] }
  Stage['setup'] -> Stage['main']

  if $::obmondo_monitoring_status { #lint:ignore:top_scope_facts
    # NOTE: Lets not allow anyone to remove our public repo, otherwise monitoring won't be setup
    # NOTE: The repo has no opkg feed, TurrisOS installs monitoring from the upstream releases.
    if $facts['os']['name'] != 'TurrisOS' {
      eit_repos::repo { 'enableit_client':
        noop_value => false,
      }
    }

    # Create Obmondo group for exporter to run under this group
    # NOTE: the group and the /opt/obmondo directories are never noop: the
    # subscription data forces obmondo_admin, monitor and openvox to apply
    # even in a noop run, and all of them need the group and directories
    # (first run on a new host fails with "group 'obmondo' does not exist"
    # and "parent directory /opt/obmondo/etc does not exist" otherwise).
    group { 'obmondo':
      ensure => present,
      system => true,
      noop   => false,
    }

    file {
      default:
        ensure => ensure_dir($::obmondo_monitor), #lint:ignore:top_scope_facts
        noop   => false,
        ;

      [
        $__conf_dir,
        $__bin_dir,
        $__opt_dir,
        "${__opt_dir}/home",
        "${__opt_dir}/share",
        "${__opt_dir}/etc",
      ]:
        ;
    }

    # NOTE: Need these classes to be setup as a bare minimum on all roles
    # These classes are loaded on each puppet run, and will be setup in noop
    lookup('common::default::classes').each | $role | {
      contain $role
    }

    # NOTE: when user only want role::basic and repo + updates with no full host management
    if 'role::basic' in $::obmondo_classes and !$full_host_management {
      lookup('common::role_basic::classes', Array, undef, []).each | $role | {
        contain $role
      }
    }

    # NOTE: full_host_management defaults to true, except for role::monitoring
    # If you need these classes, then one has to enable full_host_management
    if $full_host_management {
      contain common::backup
      contain common::logging
      contain common::network
      contain common::software
      contain common::storage
      contain common::system
      contain common::user_management
    }
  }
}
