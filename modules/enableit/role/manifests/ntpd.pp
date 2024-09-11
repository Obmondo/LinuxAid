# NTPD server role
class role::ntpd (
  Array[Stdlib::Host]     $servers,
  Optional[Boolean]       $burst    = false,
  Optional[Array[String]] $restrict = [],
  Optional[Boolean]       $tinker   = false,
  Optional[Integer[0]]    $panic    = undef,
) {

  class { '::profile::ntpd':
    servers  => $servers,
    burst    => $burst,
    restrict => $restrict,
    tinker   => $tinker,
    panic    => $panic,
  }
}

