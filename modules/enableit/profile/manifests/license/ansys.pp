# ansys license manager
class profile::license::ansys (
  Stdlib::Port $license_file_port,
  Stdlib::Port $licensing_interconnect_port = 2325,
) inherits ::profile {

  # Required for installation of Ansys
  package::install([
    'which',
    'qt-x11',
  ])

  # Necessary for running the Ansys license daemon
  file { '/lib64/ld-lsb-x86-64.so.3':
    ensure => link,
    target => '/lib64/ld-linux-x86-64.so.2',
  }

  firewall { '100 ansys license server':
    ensure => present,
    proto  => 'tcp',
    jump   => 'accept',
    dport  => [
      $license_file_port,
      $licensing_interconnect_port,
    ],
  }

}
