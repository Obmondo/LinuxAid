# frozen_string_literal: true

# @summary Converts an octet netmask address of the form 255.255.255.0 into its CIDR variant.
#          Thus making it directly usable with the values from facter.
#
Puppet::Functions.create_function(:'extlib::netmask_to_cidr') do
  # @param netmask IPv6 or IPv4 netmask in octet notation
  # @return CIDR / prefix length
  # @example calling the function
  #   extlib::netmask_to_cidr('255.0.0.0')
  dispatch :netmask_to_cidr do
    param 'Stdlib::IP::Address::Nosubnet', :netmask
    return_type 'Integer[0, 128]'
  end

  def netmask_to_cidr(netmask)
    dummy_addr = IPAddr.new(netmask).ipv6? ? '::' : '0.0.0.0'
    IPAddr.new("#{dummy_addr}/#{netmask}").prefix
  end
end
