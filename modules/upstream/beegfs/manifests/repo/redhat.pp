# Class: beegfs::repo::redhat
# @param baseurl
# @param manage_repo
# @param package_source
# @param release
#
# @api private
class beegfs::repo::redhat (
  Stdlib::HTTPUrl $baseurl        = 'https://www.beegfs.io/release',
  Boolean         $manage_repo    = true,
  Enum['beegfs']  $package_source = $beegfs::package_source,
  Beegfs::Release $release        = $beegfs::release,
) {
  $_os_release = $facts.dig('os', 'release', 'major')

  # If using version 7.1 the release folder has an underscore instead of a period
  $_release = if $release == '7.1' {
    $release.regsubst('\.', '_')
  } else {
    $release
  }

  $_gpg_key = if versioncmp($release, '7.2.5') > 0 {
    'GPG-KEY-beegfs'
  } else {
    'RPM-GPG-KEY-beegfs'
  }

  if $manage_repo {
    case $package_source {
      'beegfs': {
        yumrepo { "beegfs_rhel${_os_release}":
          ensure   => 'present',
          descr    => "BeeGFS ${release} (rhel${_os_release})",
          baseurl  => "${baseurl}/beegfs_${_release}/dists/rhel${_os_release}",
          gpgkey   => "${baseurl}/beegfs_${_release}/gpg/${_gpg_key}",
          enabled  => '1',
          gpgcheck => '1',
        }
      }
      default: {
        fail("Unknown package source '${package_source}'")
      }
    }
  }
}
