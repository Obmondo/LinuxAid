# DNS client handling
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
  Variant[Undef, Boolean]                       $noop_value           = undef,
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

  if $facts['init_system'] == 'systemd' {
    include common::monitor::exporter::dns
  }
}
