# NTP
class profile::ntpd (
  Array[Stdlib::Host]     $servers,
  Optional[Boolean]       $burst    = false,
  Optional[Array[String]] $restrict = [],
  Optional[Boolean]       $tinker   = false,
  Optional[Integer[0]]    $panic    = undef,
) {

  class { 'ntp':
    restrict      => $restrict,
    iburst_enable => $burst,
    tinker        => $tinker,
    panic         => $panic,
    servers       => $servers,
  }
}
