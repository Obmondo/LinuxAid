# APT
class eit_repos::apt {
  confine($facts['os']['family'] != 'Debian', "${facts['os']['family']} is not supported for apt repo")

  package::install('apt-transport-https')

  file { '/etc/obmondo/apt':
    ensure => directory,
  }
}
