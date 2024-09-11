#Simple class to validate and seed the correct package selection for debian based systems
define phpmyadmin::debconf (
  $selection       = '',
  $value_type      = 'string',
  $value           = '',
  $debconf_package = $::phpmyadmin::params::debconf_package,
) {
  include ::phpmyadmin::params

  #Install debconf package as needed
  ensure_packages([$debconf_package])

  #Run the actual debconf selector
  exec { $name:
    command => "/bin/echo debconf ${selection} ${value_type} ${value} | /usr/bin/debconf-set-selections",
    require => Package[$debconf_package],
    unless  => "/usr/bin/debconf-get-selections | /bin/egrep 'debconf[[:space:]]+${selection}+[[:space:]]+${value_type}+[[:space:]]+${value}'",
  }
}
