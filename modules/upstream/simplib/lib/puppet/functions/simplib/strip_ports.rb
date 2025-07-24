# Extract list of unique hostnames and/or IP addresses from an `Array`
# of hosts, each of which may may contain protocols and/or port numbers
#
# Terminates catalog compilation if
#
# * A valid network or hostname cannot be extracted from all input items.
# * Any input item that contains a port specifies an invalid port.
#
Puppet::Functions.create_function(:'simplib::strip_ports') do
  # @param hosts List of hosts which may contain protocols and port numbers.
  #
  # @return [Array[String]] Non-port portion of hostnames
  # @raise [RuntimeError] if any input item that contains a port
  #   specifies an invalid port
  #
  # @example
  #
  #   $foo = ['https://mysite.net:8443',
  #           'http://yoursite.net:8081',
  #           'https://theirsite.com']
  #
  #   $bar = simplib::strip_ports($foo)
  #
  #   $bar contains: ['mysite.net','yoursite.net','theirsite.com']
  dispatch :strip_ports do
    required_param 'Array[String[1],1]', :hosts
  end

  def strip_ports(hosts)
    call_function('simplib::parse_hosts', hosts).keys.uniq
  end
end
