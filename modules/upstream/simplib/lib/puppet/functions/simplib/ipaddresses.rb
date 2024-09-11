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
    interfaces = scope['facts']['interfaces']

    if interfaces
      interfaces.split(',').each do |iface|
        iface_addr = scope['facts']["ipaddress_#{iface}"]

        retval << iface_addr unless (iface_addr.nil? or iface_addr.strip.empty?)
      end

      retval.delete_if{|x| x =~ /^127/} if only_remote
    end

    retval
  end
end
