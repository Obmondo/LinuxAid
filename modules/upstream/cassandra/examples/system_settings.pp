# Cassandra pre-requisites
require cassandra::datastax_repo
require cassandra::system::transparent_hugepage

case "${facts['os']['name']}-${operatingsystemmajrelease}" {
  'CentOS-6': {
    $device = '/dev/mapper/VolGroup-lv_swap'
    $sysctl_args = '-e -p'
  }
  'CentOS-7': {
    $device = '/dev/mapper/centos-swap'
  }
  default: {}
}

class { 'cassandra::system::swapoff':
  device => $device,
}

if $sysctl_args {
  class { 'cassandra::system::sysctl':
    sysctl_args => $sysctl_args,
  }
} else {
  require cassandra::system::sysctl
}
