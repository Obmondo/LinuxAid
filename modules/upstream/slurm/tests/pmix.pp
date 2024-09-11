# Test download and build of PMIx sources
#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply --modulepath /vagrant/tests/vagrant/puppet/modules -t /vagrant/tests/pmix.pp
#
node default {

  include ::slurm::params

  $version = $::slurm::params::pmix_version
  $checksum = $::slurm::params::pmix_src_checksum
  $ensure = 'present'
  # $ensure = 'absent'

  class { 'slurm::pmix':
    ensure  => $ensure,
    version => $version,
  }

  # slurm::pmix::download { $version:
  #   ensure => $ensure,
  # }
  # slurm::pmix::build { $version:
  #   ensure => $ensure,
  #   #defines => [ 'install_in_opt 1' ],
  #   require => Slurm::Pmix::Download[$version]
  # }
  # slurm::pmix::install { $version:
  #   ensure => $ensure,
  #   require => Slurm::Pmix::Build[$version]
  # }

}
