# frozen_string_literal: true

require 'ipaddr'

# @summary Returns a boolean indicating whether an IP address is part of a network CIDR
Puppet::Functions.create_function(:'extlib::is_in_cidr') do
  # @param ip
  #   IPv4 or IPv6 address
  # @param cidr
  #   CIDR you want to check whether the IP address is in or not
  #
  # @example Calling the function
  #   '192.0.2.42'.extlib::is_in_cidr('192.0.2.0/24')
  dispatch :ip_is_in_cidr? do
    param 'Stdlib::IP::Address::Nosubnet', :ip
    param 'Variant[Stdlib::IP::Address::V4::CIDR,Stdlib::IP::Address::V6::CIDR]', :cidr
    return_type 'Boolean'
  end

  def ip_is_in_cidr?(ip, cidr)
    IPAddr.new(cidr).include? IPAddr.new(ip)
  end
end
