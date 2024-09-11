# Class: beegfs::repo::redhat

class beegfs::repo::redhat (
  Boolean         $manage_repo    = true,
  Enum['beegfs']  $package_source = $beegfs::package_source,
                  $package_ensure = $beegfs::package_ensure,
  Beegfs::Release $release        = $beegfs::release,
) {

  $_os_release = $facts.dig('os', 'release', 'major')

  # If using the old version pattern the release folder is the same as the major
  # version; if using the new pattern we need to replace dots (`.`) with spaces
  # (` `)
  $_release = if $release =~ /^\d{4}/ {
    $release
  } else {
    $release.regsubst('\.', '_')
  }

  if $manage_repo {
    case $package_source {
      'beegfs': {
        yumrepo { "beegfs_rhel${_os_release}":
          ensure    => 'present',
          descr     => "BeeGFS ${release} (rhel${_os_release})",
          baseurl   => "https://www.beegfs.io/release/beegfs_${_release}/dists/rhel${_os_release}",
          gpgkey    => "https://www.beegfs.io/release/beegfs_${_release}/gpg/RPM-GPG-KEY-beegfs",
          enabled   => '1',
          gpgcheck  => '1',
        }
      }
    }
  }
}
