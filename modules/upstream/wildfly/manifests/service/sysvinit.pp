# Wildfly sysvinit configuration
#
class wildfly::service::sysvinit {
  $service_file = pick($wildfly::custom_init, "${wildfly::dirname}/${wildfly::service::service_file}")

  if $::wildfly::custom_init {
    # Pass custom initd script template for starting wildfly
    file { "/etc/init.d/${wildfly::service::service_name}":
      ensure  => present,
      mode    => '0755',
      content => epp($service_file),
      notify  => Service[$wildfly::service::service_name],
    }
  } else {
    # Use/Copy default initd script from installation
    file { "/etc/init.d/${wildfly::service::service_name}":
      ensure => present,
      mode   => '0755',
      source => $service_file,
      notify => Service[$wildfly::service::service_name],
    }
  }

}
