# frozen_string_literal: true

# Imported by Tim 'bastelfreak' Meusel into voxpupuli/extlib because Yelp/netstdlib got abandoned
#
# @summary Converts a CIDR address of the form 2001:DB8::/32 or 192.0.2.0/24 into their network address (also known as net address)
#
Puppet::Functions.create_function(:'extlib::cidr_to_network') do
  # @param ip IPv6 or IPv4 address in CIDR notation
  # @return IPv6 or IPv4 network/net address
  # @example calling the function
  #   extlib::cidr_to_network('2001:DB8::/32')
  dispatch :cidr_to_network do
    param 'Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]', :ip
    return_type 'Variant[Stdlib::IP::Address::V4::Nosubnet,Stdlib::IP::Address::V6::Nosubnet]'
  end

  def cidr_to_network(ip)
    IPAddr.new(ip).to_range.first.to_s
  end
end
