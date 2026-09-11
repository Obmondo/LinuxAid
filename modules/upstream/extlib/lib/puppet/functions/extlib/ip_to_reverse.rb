# frozen_string_literal: true

require 'ipaddr'

# @summary Returns the reverse of an IP address
#
# No actual query is done to the DNS server, it only calculate the record that
# could be added to a DNS zone file.
#
# If you want to effectively make a query, see Vox Pupuli dns-query module:
# https://github.com/voxpupuli/puppet-dnsquery
Puppet::Functions.create_function(:'extlib::ip_to_reverse') do
  # @param ip
  #   IPv4 or IPv6 address
  #
  # @example Calling the function
  #   extlib::ip_to_reverse('192.0.2.0')
  dispatch :ip_to_reverse do
    param 'Stdlib::IP::Address', :ip
    return_type 'String'
  end

  def ip_to_reverse(ip)
    IPAddr.new(ip).reverse
  end
end
