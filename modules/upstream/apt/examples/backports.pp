# Set up a backport for Linux Mint qiana
class { 'apt': }
class { 'apt::backports':
  location => 'http://us.archive.ubuntu.com/ubuntu',
  release  => 'trusty-backports',
  repos    => 'main universe multiverse restricted',
}
