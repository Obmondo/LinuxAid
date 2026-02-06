# @summary Class for handling DNS client configuration
#
# @param resolver The DNS resolver to use. Valid values are 'dnsmasq', 'systemd-resolved', or 'resolv'.
#
# @param manage Whether to manage DNS configuration. Defaults to false.
#
# @param nameservers List of DNS nameservers. Defaults to an empty array.
#
# @param fallback_nameservers List of fallback DNS nameservers. Defaults to an empty array.
#
# @param searchpath DNS search path. Defaults to an empty array.
#
# @param dnssec Enable DNSSEC validation. Can be Boolean or 'allow-downgrade'. Defaults to false.
#
# @param dns_over_tls Enable DNS over TLS. Can be Boolean or 'opportunistic'. Defaults to false.
#
# @param listen_address List of IP addresses to listen on. Defaults to an empty array.
#
# @param allow_external Allow external DNS queries. Defaults to false.
#
# @param noop_value Value used for noop operations. Defaults to undef.
#
# @groups configuration resolver, manage, nameservers, fallback_nameservers, searchpath.
#
# @groups security dnssec, dns_over_tls, allow_external.
#
# @groups network listen_address.
#
# @groups operations noop_value.
#
class common::system::dns (
  Enum['dnsmasq', 'systemd-resolved', 'resolv'] $resolver,
  Boolean                                       $manage               = false,
  Array                                         $nameservers          = [],
  Array                                         $fallback_nameservers = [],
  Array[Eit_types::Hostname]                    $searchpath           = [],
  Variant[Boolean, Enum['allow-downgrade']]     $dnssec               = false,
  Variant[Boolean, Enum['opportunistic']]       $dns_over_tls         = false,
  Array[Stdlib::IP::Address]                    $listen_address       = [],
  Boolean                                       $allow_external       = false,
  Eit_types::Noop_Value                         $noop_value           = undef,
) inherits common::system {

  confine($manage, $nameservers.count == 0,
          '`$nameservers` must have one or more values.')
  confine($manage, $resolver != 'systemd-resolved', $dnssec or $dns_over_tls,
          "`\$dnssec` and `\$dns_over_tls` are not available for resolver '${resolver}'")
  confine($manage, $allow_external, $resolver != 'dnsmasq',
          'Only `dnsmasq` can be used with `$allow_external`')

  if $manage {
    contain profile::system::dns
    contain profile::system::systemd
  }

  # if $facts['init_system'] == 'systemd' {
  #   include common::monitor::exporter::dns
  # }
}
