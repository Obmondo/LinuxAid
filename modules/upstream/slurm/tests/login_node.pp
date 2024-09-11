#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/login_node.pp
#
node default {
  #include ::slurm::params

  include ::slurm
  include ::slurm::login
}
