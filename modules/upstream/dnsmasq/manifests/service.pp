class dnsmasq::service (
  Variant[String, Boolean] $service_control = $dnsmasq::params::service_control,
) {
  # validate type and convert string to boolean if necessary
  if $service_control =~ String {
    $service_control_real = Boolean($service_control)
  } else {
    $service_control_real = $service_control
  }
  if $service_control_real == true {
    service { $dnsmasq::params::service_name:
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
