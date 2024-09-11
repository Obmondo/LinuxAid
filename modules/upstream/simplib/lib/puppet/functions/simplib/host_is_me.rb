# Detect if a local system identifier hostname/IPv4 address matches
# a specified hostname/IPv4 address or an entry in a list of 
# hostnames and/or IPv4 addresses
#
Puppet::Functions.create_function(:'simplib::host_is_me') do

  # @param host Hostname/IPv4 address to compare against;
  #   `127.0.0.1` is never matched, use `localhost` instead
  # @return [Boolean] true if a local system hostname/IPv4 address matches
  #   the specified host
  dispatch :host_is_me do
    required_param 'Simplib::Host', :host
  end

  # @param hosts Array of Hostnames and/or IPv4 addresses to compare
  #   against; `127.0.0.1` is never matched, use `localhost` instead
  # @return [Boolean] true if a local system hostname/IPv4 address matches
  #   any of the specified hosts
  dispatch :hostlist_contains_me do
    required_param 'Array[Simplib::Host]', :hosts
  end

  def host_is_me(host)
    hostlist_contains_me(Array(host))
  end

  def hostlist_contains_me(hosts)
    retval = false
    scope = closure_scope

    host_identifiers = [
      scope['facts']['fqdn'],
      scope['facts']['hostname'],
      'localhost',
      'localhost.localdomain'
    ]

    # add non-local IPv4 addresses
    host_identifiers += call_function('simplib::ipaddresses', true)

    hosts.each do |id|
      if host_identifiers.include?(id)
        retval = true
        break
      end
    end

    retval
  end
end
