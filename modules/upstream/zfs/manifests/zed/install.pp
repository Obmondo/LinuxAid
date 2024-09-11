# @!visibility private
class zfs::zed::install {

  if $zfs::zed::package_name {
    package { $zfs::zed::package_name:
      ensure => present,
    }
  }
}
