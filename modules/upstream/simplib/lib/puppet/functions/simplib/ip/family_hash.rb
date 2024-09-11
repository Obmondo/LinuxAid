# Process an array of IP addresses and return them split by IP family and
# include metadata and/or processed versions.
#
Puppet::Functions.create_function(:'simplib::ip::family_hash') do
  # @param ip_addresses
  #   The addresses to convert
  #
  # @return [Hash]
  #   Converted Hash with the following format (YAML representation):
  #
  #   ```
  #   # IPv4 Addresses
  #   ipv4:
  #     <Passed Address>:
  #       address: <normalized address>
  #       netmask:
  #         ddq: <dotted quad notation netmask>
  #         cidr: <CIDR netmask>
  #   # IPv6 Addresses
  #   ipv6:
  #     <Passed Address>:
  #       address: <normalized address>
  #       netmask:
  #         # DDQ is not valid for IPv6
  #         ddq: nil
  #         cidr: <CIDR netmask>
  #   ```
  #
  # @example
  #
  #   simplib::ip::family_hash([
  #     '1.2.3.4',
  #     '2.3.4.5/8',
  #     '::1'
  #   ])
  #
  #   Returns (YAML Formatted for clarity)
  #
  #   ---
  #   ipv4:
  #     '1.2.3.4':
  #       address: '1.2.3.4'
  #       netmask:
  #         ddq: '255.255.255.255'
  #         cidr: 32
  #     '2.3.4.5/8':
  #       address: '2.0.0.0'
  #       netmask:
  #         ddq: '255.0.0.0'
  #         cidr: 8
  #   ipv6:
  #     '::1':
  #       address: '[::1]'
  #       netmask:
  #         ddq: nil
  #         cidr: 128
  #
  dispatch :family_hash do
    required_param 'Variant[
      Simplib::Host,
      Simplib::IP::V4::DDQ,
      Simplib::IP::V4::CIDR,
      Simplib::IP::V6::CIDR,
      Simplib::Netlist
    ]', :ip_addresses
  end

  def family_hash(addresses)
    results = {}

    Array(addresses).uniq.each do |addr|
      ip_breakdown = {
        'address' => addr,
        'netmask' => {
          'ddq'  => nil,
          'cidr' => nil
        }
      }

      begin
        ip = IPAddr.new(addr)

        addr_normalized, cidr_netmask = call_function('simplib::nets2cidr', addr).
          first.split('/')

        addr_normalized.delete!('[]')

        ip_breakdown['address'] = addr_normalized
        ip_breakdown['netmask']['cidr'] = cidr_netmask && cidr_netmask.to_i

        if ip.ipv4?
          ip_family = 'ipv4'

          ip_breakdown['netmask']['ddq'] = call_function('simplib::nets2ddq', addr).
            first.split('/')[1] || '255.255.255.255'

          ip_breakdown['netmask']['cidr'] = 32 unless ip_breakdown['netmask']['cidr']
        elsif ip.ipv6?
          ip_family = 'ipv6'

          ip_breakdown['netmask']['cidr'] = 128 unless ip_breakdown['netmask']['cidr']
        else
          ip_family = 'unknown'
        end
      rescue
        ip_family = 'unknown'
      end


      results[ip_family] ||= {}
      results[ip_family][addr] = ip_breakdown
    end

    results
  end
end
