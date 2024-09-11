# == Class beegfs::params
#
# This class is meant to be called from beegfs.
# It sets variables according to platform.
#
class beegfs::params {

  case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['name'] {
        'Debian': {
          $kernel_packages = ['linux-headers-amd64']

          $dist = has_key($facts['os'], 'distro') ? {
            true =>  $facts['os']['distro']['codename'], # puppet 4.10.6 (puppetlabs)
            false =>  $facts['os']['lsb']['distcodename'] # puppet 4.8.2 (debian) WHY?!
          }

          case $dist {
            'wheezy': {
              $release = 'deb7'
            }
            'squeeze': {
              $release = 'deb6'
            }
            'jessie': {
              $release = 'deb8'
            }
            'stretch': {
              $release = 'deb9'
            }
            default: {
              $release = 'deb8'
            }
          }
        }
        'Ubuntu': {
          $kernel_packages = ['linux-headers-generic']
          case $facts['os']['distro']['codename'] {
            'precise': {
              $release = 'deb7'
            }
            'trusty','xenial': {
              $release = 'deb8'
            }
            'zesty':{
              $release = 'deb9'
            }
            default: {
              $release = 'deb9'
            }
          }
        }
        default: {
          fail("Family: ${facts['os']['family']} OS: ${facts['os']['name']} is not supported yet") #"
        }
      }
    }
    'RedHat': {
      $kernel_packages = ['kernel-devel']
      $repo_defaults = {
        '2015.03' => {
          'descr'   => "BeeGFS 2015.03 (RHEL${facts['os']['release']['major']})",
          'baseurl' => "http://www.beegfs.com/release/beegfs_2015.03/dists/rhel${facts['os']['release']['major']}",
          'gpgkey'  => 'http://www.beegfs.com/release/beegfs_2015.03/gpg/RPM-GPG-KEY-beegfs',
        },
      }
      $release = 'redhat'
    }
    default: {
      fail("Family: ${facts['os']['family']} OS: ${facts['os']['name']} is not supported yet") #"
    }
  }
}
