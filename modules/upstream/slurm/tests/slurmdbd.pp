#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply --modulepath /vagrant/tests/vagrant/puppet/modules  -t /vagrant/tests/slurmdbd.pp
#
node default {
  # include ::slurm::params

  include slurm
  class { 'slurm::slurmdbd':
    privatedata => ['accounts', 'users', 'usage', 'jobs'],
  }
}
