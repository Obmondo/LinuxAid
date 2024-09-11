# == Class: curator::repo
#
# This class exists to install and manage yum and apt repositories
# that contain official curator packages
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'curator::repo': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Petter Abrahamsson <mailto:petter@jebus.nu>
# * Phil Fenstermacher <mailto:phillip.fenstermacher@gmail.com>
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class curator::repo {

  case $::osfamily {
    'Debian': {
      if !defined(Class['apt']) {
        class { '::apt': }
      }

      if versioncmp($::os['release']['major'], '9') == 0 {
        $repo_path = '9'
      } else {
        $repo_path = ''
      }

      apt::source { 'curator':
        location => "http://packages.elastic.co/curator/${curator::repo_version}/debian${repo_path}",
        release  => 'stable',
        repos    => 'main',
        key      => {
          id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          server => 'pgp.mit.edu'
        },
        include  => {
          src => false,
          deb => true
        }
      } -> Class['apt::update'] -> Package[$curator::package_name]
    }
    'RedHat': {
      # Support for facter 3
      if $::operatingsystemmajrelease {
        $_ver = $::operatingsystemmajrelease
      } else {
        $_ver =$::os['release']['major']
      }

      yumrepo { 'curator':
        descr    => 'Curator Centos Repo',
        baseurl  => "http://packages.elastic.co/curator/${curator::repo_version}/centos/${_ver}",
        gpgcheck => 1,
        gpgkey   => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
        enabled  => 1,
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}
