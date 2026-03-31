# @summary Class for managing DHCP server configuration
#
# @param manage Whether to manage the DHCP server. Defaults to false.
#
# @param enable Whether to enable the DHCP service. Defaults to true.
#
# @param interfaces Array of network interfaces to listen on. Required when manage is true.
#
# @param dnsdomain DNS domain name(s) for the DHCP scope. Defaults to undef (uses fact).
#
# @param nameservers Array of IPv4 DNS servers to hand out. Defaults to empty array.
#
# @param dnssearchdomains Array of DNS search domains. Defaults to empty array.
#
# @param authoritative Whether this server is authoritative. Defaults to true.
#
# @param default_lease_time Default lease time in seconds. Defaults to 43200.
#
# @param max_lease_time Maximum lease time in seconds. Defaults to 86400.
#
# @param pools Hash of DHCP pool configurations. Defaults to empty hash.
#
# @param hosts Hash of static DHCP host reservations. Defaults to empty hash.
#
# @param ignoredsubnets Optional hash of ignored subnet configurations. Defaults to undef.
#
# @groups service_control manage, enable.
#
# @groups network interfaces, dnsdomain, nameservers, dnssearchdomains.
#
# @groups lease authoritative, default_lease_time, max_lease_time.
#
# @groups pools pools, hosts, ignoredsubnets.
#
class common::network::dhcpd (
  Boolean                    $manage             = false,
  Boolean                    $enable             = true,
  Optional[Array[String[1]]] $interfaces         = undef,
  Optional[Array[String[1]]] $dnsdomain          = undef,
  Array[Stdlib::IP::Address::V4] $nameservers    = [],
  Array[String[1]]           $dnssearchdomains   = [],
  Boolean                    $authoritative      = true,
  Integer[-1]                $default_lease_time = 43200,
  Integer[-1]                $max_lease_time     = 86400,
  Eit_types::Network::Dhcp::Pool           $pools              = {},
  Eit_types::Network::Dhcp::Host           $hosts              = {},
  Optional[Eit_types::Network::Dhcp::Ignoredsubnet] $ignoredsubnets = undef,
) {
  if $manage {
    $_service_ensure = $enable ? { true => 'running', default => 'stopped' }

    class { '::dhcp':
      interfaces         => $interfaces,
      dnsdomain          => $dnsdomain,
      nameservers        => $nameservers,
      dnssearchdomains   => $dnssearchdomains,
      authoritative      => $authoritative,
      default_lease_time => $default_lease_time,
      max_lease_time     => $max_lease_time,
      pools              => $pools,
      hosts              => $hosts,
      ignoredsubnets     => $ignoredsubnets ? { undef => {}, default => $ignoredsubnets },
      service_ensure     => $_service_ensure,
    }
  }
}
