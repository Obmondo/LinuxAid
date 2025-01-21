# Obmondo monitoring
class monitor (
  Boolean $enable     = $facts['obmondo_monitoring_status'],
  Boolean $noop_value = false,
) {

  if $enable {
    contain monitor::prometheus
    contain monitor::raid
    contain monitor::system
    contain monitor::service
  }
}
