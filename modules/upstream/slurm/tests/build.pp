# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply --modulepath /vagrant/tests/vagrant/puppet/modules -vt /vagrant/tests/build.pp
#
node default {
  require slurm::params
  $version = $::slurm::params::version
  $ensure  = 'present' #'absent'

  slurm::download { $version:
    ensure => $ensure,
  }
  slurm::build { $version:
    ensure => $ensure,
  }
}
