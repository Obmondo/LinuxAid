# Storage-related stuff
#
# FIXME: this should run in the setup stage for easier dependency ordering
class profile::storage (
  Eit_types::Common::Storage::Mounts $mounts = $common::storage::mounts,
) inherits ::profile {

  $_dirs = $mounts.functions::knockout.keys.map |$d| {
    functions::dir_to_dirs($d)
  }.flatten.sort.unique.filter |$d| {
    # we need to remove /var/log since we already manage it from
    # profile::logging
    $d != '/var/log'
  }

  file { $_dirs:
    ensure => directory,
    mode   => undef,
    owner  => undef,
    group  => undef,
  }

  $mounts.functions::knockout.each |$_name, $_mount| {
    profile::storage::mount { "mount ${_name}":
      path    => $_name,
      *       => $_mount,
      require => File[$_name],
    }
  }
}
