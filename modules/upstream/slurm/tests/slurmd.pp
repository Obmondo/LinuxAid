#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/slurmd.pp
#
node default {
  #include ::slurm::params

  class { '::slurm':
    service_manage  => false,
    manage_firewall => true,
  }
  include ::slurm::slurmd
}
