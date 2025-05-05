# Class: beegfs::repo
#
# Manage beegfs repository installation
#
# @param release
# @param manage_repo
# @param package_source
# @param dist
#
# @api private
class beegfs::repo (
  Beegfs::Release       $release,
  Boolean               $manage_repo    = $beegfs::manage_repo,
  Beegfs::PackageSource $package_source = $beegfs::package_source,
  Optional[String]      $dist           = undef,
) {
  case $facts['os']['family'] {
    'Debian': {
      class { 'beegfs::repo::debian':
        release => $release,
        dist    => $dist,
      }
    }
    'RedHat': {
      contain beegfs::repo::redhat
    }
    default: {
      fail("Module '${module_name}' is not supported on OS: '${facts['os']['name']}', family: '${facts['os']['family']}'")
    }
  }
}
