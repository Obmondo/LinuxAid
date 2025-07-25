# Return an `Array` of all IPv4 addresses known to be associated with the
# client, optionally excluding local addresses.
#
Puppet::Functions.create_function(:'simplib::ipaddresses') do
  # @param only_remote Whether to exclude local addresses
  #   from the return value (e.g., '127.0.0.1').
  #
  # @return [Array[String]] List of IP addresses for the client
  dispatch :ipaddresses do
    optional_param 'Boolean', :only_remote
  end

  def ipaddresses(only_remote = false)
    retval = []
    scope = closure_scope
    interfaces = scope['facts'].dig('networking', 'interfaces')

    if interfaces.is_a?(Hash) && !interfaces.empty?
      retval = interfaces.select { |_, v| v['ip'].is_a?(String) && !v['ip'].empty? }.map { |_, v| v['ip'] }

      retval.delete_if { |x| x =~ %r{^127} } if only_remote
    end

    retval
  end
end
