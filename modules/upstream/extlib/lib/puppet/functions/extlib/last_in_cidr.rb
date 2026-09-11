# frozen_string_literal: true

# Imported by Tim 'bastelfreak' Meusel into voxpupuli/extlib because Yelp/netstdlib got abandoned
#
# @summary Converts an IPv4 or IPv6 CIDR address of the form 192.0.2.1/24 or 2001:db8::1/64 into the last address in the network
Puppet::Functions.create_function(:'extlib::last_in_cidr') do
  # @param ip IP address in CIDR notation
  # @return last address in the network
  # @example calling the function
  #   extlib::last_in_cidr('127.0.0.1/8')
  dispatch :last_in_cidr do
    param 'Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]', :ip
    return_type 'Variant[Stdlib::IP::Address::V4::Nosubnet,Stdlib::IP::Address::V6::Nosubnet]'
  end

  def last_in_cidr(ip)
    IPAddr.new(ip).to_range.last.to_s
  end
end
