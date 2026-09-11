# frozen_string_literal: true

# Imported by Tim 'bastelfreak' Meusel into voxpupuli/extlib because Yelp/netstdlib got abandoned
#
# @summary Converts an CIDR address of the form 192.168.0.1/24 into its netmask.
#
Puppet::Functions.create_function(:'extlib::cidr_to_netmask') do
  # @param ip IPv6 or IPv4 address in CIDR notation
  # @return IPv6 or IPv4 netmask address
  # @example calling the function
  #   extlib::cidr_to_netmask('127.0.0.1/8')
  dispatch :cidr_to_netmask do
    param 'Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]', :ip
    return_type 'Variant[Stdlib::IP::Address::V4::Nosubnet,Stdlib::IP::Address::V6::Nosubnet]'
  end

  def cidr_to_netmask(ip)
    # IPAddr has no getter for the subnetmask, but inspect() returns it
    IPAddr.new(ip).inspect.gsub(%r{.*/(.*)>}, '\1')
  end
end
