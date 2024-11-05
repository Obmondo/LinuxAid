# Obmondo system monitoring
class monitor::system (
) {

  contain monitor::system::cpu
  contain monitor::system::disk
  contain monitor::system::load
  contain monitor::system::ntp
  contain monitor::system::psi
  contain monitor::system::ram
  contain monitor::system::service
  contain monitor::system::file_size
  contain monitor::system::hwmon
  contain monitor::system::dns

  if $facts['drbdpeerstate1'] {
    contain monitor::system::drbd
  }
}
