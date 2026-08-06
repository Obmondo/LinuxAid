# NTP
class profile::system::ntpd (
  Array[Stdlib::Host] $servers,
) {

  class { 'ntp':
    restrict      => [],
    iburst_enable => false,
    tinker        => false,
    panic         => undef,
    servers       => $servers,
  }
}
