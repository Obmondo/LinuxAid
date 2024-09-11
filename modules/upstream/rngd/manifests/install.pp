# @!visibility private
class rngd::install {

  package { $::rngd::package_name:
    ensure => present,
  }
}
