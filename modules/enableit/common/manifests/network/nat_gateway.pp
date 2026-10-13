# @summary Class for turning a host into a NAT gateway
#
# Thin wrapper around profile::network::nat_gateway. Disabled by default; enable
# it per host from linuxaid-config hiera with
# `common::network::nat_gateway::enable: true`.
#
# The host then forwards IPv4 traffic and masquerades what leaves through its
# public interface. Both settings are saved, so they survive a reboot.
#
# The switch is read in the common class, so it also works on hosts without
# full host management.
#
# @param enable Whether the host acts as a NAT gateway. Defaults to false.
#
# @param noop_value Noop value for the resources of this class. Defaults to
#   undef. Set it to false on a host that runs in noop mode, otherwise the
#   changes are only reported.
#
# @param source Networks to masquerade, in CIDR notation. Defaults to [], which
#   masquerades everything that leaves through `out_interface`.
#
# @param out_interface Interface the masqueraded traffic leaves through.
#   Defaults to the interface of the default route.
#
# @groups management enable, noop_value
#
# @groups configuration source, out_interface
#
class common::network::nat_gateway (
  Boolean                              $enable        = false,
  Eit_types::Noop_Value                $noop_value    = undef,
  Array[Stdlib::IP::Address::V4::CIDR] $source        = [],
  Optional[String[1]]                  $out_interface = undef,
) {
  include profile::network::nat_gateway
}
