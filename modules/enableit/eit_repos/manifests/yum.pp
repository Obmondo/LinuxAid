# Yum
class eit_repos::yum {
  confine($facts['os']['family'] != 'RedHat', "${facts['os']['family']} is not supported for yum repo")
}
