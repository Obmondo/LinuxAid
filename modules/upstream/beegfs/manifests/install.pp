# == Class beegfs::install
#
# This class is called from beegfs for install.
#
class beegfs::install(
  $manage_repo    = $beegfs::manage_repo,
  $package_source = $beegfs::package_source,
  $package_ensure = $beegfs::package_ensure,
  $log_dir        = $beegfs::log_dir,
  $user           = $beegfs::user,
  $group          = $beegfs::group,
  $release        = $beegfs::params::release,
  ) {

  class {'::beegfs::repo':
    manage_repo    => $manage_repo,
    package_source => $package_source,
    release        => $release,
  }

  anchor { 'beegfs::user' : }

  user { 'beegfs':
    ensure => present,
    before => Anchor['beegfs::user'],
  }

  group { 'beegfs':
    ensure => present,
    before => Anchor['beegfs::user'],
  }

  # make sure log directory exists
  ensure_resource('file', $log_dir, {
    'ensure' => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Anchor['beegfs::user'],
  })

  package { 'beegfs-utils':
    ensure  => $package_ensure,
    require => [Anchor['beegfs::repo::end']],
  }

}
