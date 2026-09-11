# frozen_string_literal: true

require 'ipaddr'

# A function that compares two IP addresses. To be used with the built-in sort()
# function.
Puppet::Functions.create_function(:'extlib::compare_ip') do
  # @param left Left value
  # @param right Right value
  # @return -1, 0 or 1 if left value is lesser, equal or greater than right value
  # @example Sorting the array of IP addresses
  #   $ip_addresses = ['10.1.1.1', '10.10.1.1', '10.2.1.1']
  #   $ip_addresses.sort |$a, $b| { extlib::compare_ip($a, $b) }
  dispatch :compare_ip do
    param 'Stdlib::IP::Address', :left
    param 'Stdlib::IP::Address', :right
    return_type 'Integer[-1,1]'
  end

  def compare_ip(left, right)
    IPAddr.new(left).to_i <=> IPAddr.new(right).to_i
  end
end
