# = Class perforce::repository
#
# == Description
# install and configure the Perforce package repository
#
class perforce::repository {

  yumrepo { 'perforce':
    descr    => 'Perforce Repository',
    baseurl  => "https://package.perforce.com/yum/rhel/${::os['release']['major']}/x86_64",
    gpgkey   => 'https://package.perforce.com/perforce.pubkey',
    gpgcheck => true,
    enabled  => true,
  }
}