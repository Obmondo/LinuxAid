# == Class beegfs::install
#
# This class is called from beegfs for install.
#
# @param manage_repo
# @param package_source
# @param package_ensure
# @param log_dir
# @param user
# @param group
# @param release
# @param dist
#   override OS distribution detection
#
# @api private
class beegfs::install (
  Boolean               $manage_repo    = $beegfs::manage_repo,
  Beegfs::PackageSource $package_source = $beegfs::package_source,
  String                $package_ensure = $beegfs::package_ensure,
  Beegfs::LogDir        $log_dir        = $beegfs::log_dir,
  String                $user           = $beegfs::user,
  String                $group          = $beegfs::group,
  Beegfs::Release       $release        = $beegfs::release,
  Optional[String]      $dist           = undef,
) {
  class { 'beegfs::repo':
    manage_repo    => $manage_repo,
    package_source => $package_source,
    release        => $release,
    dist           => $dist,
  }

  user { 'beegfs':
    ensure => present,
  }

  group { 'beegfs':
    ensure  => present,
  }

  # make sure log directory exists
  ensure_resource('file', $log_dir, {
      'ensure' => directory,
      owner   => $user,
      group   => $group,
      recurse => true,
  })

  stdlib::ensure_packages(['beegfs-utils'], {
      'ensure'  => $package_ensure,
      'require' => Class['beegfs::repo']
  })
}
