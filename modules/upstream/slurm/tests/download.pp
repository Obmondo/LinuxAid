# Test download of SLURM sources
#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply --modulepath /vagrant/tests/vagrant/puppet/modules -t /vagrant/tests/download.pp
#
node default {

  include ::slurm::params
  $ensure = 'present'
  # $ensure = 'absent'

  slurm::download { $::slurm::params::version:
    ensure => $ensure,
  }
  slurm::download { 'slurm-18.08.8.tar.bz2':
    ensure   => $ensure,
    checksum => '4a2c176b54a56763704bcc7abfd9b8a4f91c82b8',
  }

}
