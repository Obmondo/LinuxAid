# Setup percona repo
class xtrabackup::repo inherits xtrabackup {

  if $xtrabackup::manage_repo == true {

    case $::operatingsystem {
      'RedHat', 'CentOS': {
        yumrepo { 'percona':
          descr    => 'CentOS $releasever - Percona',
          baseurl  => 'http://repo.percona.com/centos/$releasever/os/$basearch/',
          gpgkey   => 'http://www.percona.com/downloads/percona-release/RPM-GPG-KEY-percona',
          enabled  => 1,
          gpgcheck => 1,
        }
      }

      /^(Debian|Ubuntu)$/:{
        include apt
        apt::source { 'percona':
          ensure   => present,
          include  => { src => true },
          location => 'http://repo.percona.com/apt',
          release  => $::lsbdistcodename,
          repos    => 'main',
          key      => '4D1BB29D63D98E422B2113B19334A25F8507EFA5',
        }
      }

      default: {
        fail("Module ${module_name} is not supported on ${::operatingsystem}")
      }
    }
  }
}
