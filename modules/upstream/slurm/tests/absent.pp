#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/absent.pp
#      sudo puppet apply -t /vagrant/tests/clean.pp
#
node default {
  class { 'slurm':
    ensure         => 'absent',
    with_slurmdbd  => true,
    with_slurmctld => true,
    with_slurmd    => true,
    #manage_munge   => false,
  }
  # class { 'slurm::munge':
  #   ensure => 'absent'
  # }
}
