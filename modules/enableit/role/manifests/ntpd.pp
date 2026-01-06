
# @summary Class for managing the NTPD server role
#
# @param servers The list of NTPD servers. No default value.
#
# @param burst Whether to enable burst mode. Defaults to false.
#
# @param restrict The list of restrict configurations. Defaults to an empty array.
#
# @param tinker Whether to enable tinker options. Defaults to false.
#
# @param panic The panic threshold in seconds. Defaults to undef.
#
# @groups config burst, restrict, tinker, panic
#
# @groups network servers
#
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
