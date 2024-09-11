# Convert an `Array` of items that may contain port numbers or protocols
# into a structured `Hash` of host information.
#
# * Works with Hostnames as well as IPv4 and IPv6 addresses.
# * IPv6 addresses will be returned normalized with square brackets
#   around them for clarity.
# * Terminates catalog compilation if
#
#     * A valid network or hostname cannot be extracted from all input items.
#     * Any input item that contains a port specifies an invalid port.
#
Puppet::Functions.create_function(:'simplib::parse_hosts') do

  # @param hosts Array of host entries, where each entry may contain
  #   a protocol or both a protocol and port
  # @return [Hash] Structured Hash of the host information
  # @raise [RuntimeError] if a valid network or hostname cannot be
  #   extracted from all input items
  # @raise [RuntimeError] if any input item that contains a port
  #   specifies an invalid port
  # @example Input with multiple host formats:
  #
  #   simplib::parse_hosts([
  #     '1.2.3.4',
  #     'http://1.2.3.4',
  #     'https://1.2.3.4:443'
  #   ])
  #
  #   Returns:
  #
  #   {
  #     '1.2.3.4' => {
  #       :ports     => ['443'],
  #       :protocols => {
  #         'http'  => [],
  #         'https' => ['443']
  #       }
  #     }
  #   }
  dispatch :parse_hosts do
    required_param 'Array[String[1],1]', :hosts
  end

  def parse_hosts(hosts)
    # Parse!
    parsed_hosts = {}
    hosts.each do |host|

      host = host.strip

      next if host.nil? || host.empty?
      tmp_host = host

      # Initialize.
      protocol = nil
      port = nil
      hostname = nil

      # Get the protocol.
      tmp_host = host.split('://')
      if tmp_host.size == 1
        hostname = tmp_host.first
      else
        protocol = tmp_host.first
        hostname = tmp_host.last
      end

      # Validate with the protocol stripped off
      call_function('simplib::validate_net_list', Array(hostname))

      hostname,port = PuppetX::SIMP::Simplib.split_port(hostname)
      call_function('simplib::validate_port', Array(port)) if (port && !port.empty?)

      # Build a unique list of parsed hosts.
      unless parsed_hosts.key?(hostname)
        parsed_hosts[hostname] = {
          :ports     => [],
          :protocols => {}
        }
      end

      if port
        parsed_hosts[hostname][:ports] << port
      end

      if protocol
        parsed_hosts[hostname][:protocols] = {} unless parsed_hosts[hostname][:protocols]
        parsed_hosts[hostname][:protocols][protocol] = [] unless parsed_hosts[hostname][:protocols][protocol]

        parsed_hosts[hostname][:protocols][protocol] << port if port
      end
    end

    parsed_hosts.keys.each do |host|
      unless parsed_hosts[host][:ports].empty?
        parsed_hosts[host][:ports].uniq!
        parsed_hosts[host][:ports].sort!
      end

      parsed_hosts[host][:protocols].each_key do |protocol|
        unless parsed_hosts[host][:protocols][protocol].empty?
          parsed_hosts[host][:protocols][protocol].uniq!
          parsed_hosts[host][:protocols][protocol].sort!
        end
      end
    end

    parsed_hosts
  end
end
