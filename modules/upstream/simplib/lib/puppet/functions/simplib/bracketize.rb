# Add brackets to strings of IPv6 addresses and `Arrays`
# of IPv6 addresses based on the rules for bracketing
# IPv6 addresses.
#
# Ignores anything that does not look like an IPv6 address
# and return those entries untouched.
#
Puppet::Functions.create_function(:'simplib::bracketize') do
  # @param ip_arr The array of IPv6 addresses to bracketize
  # @return [Variant[String, Array[String]]] converted input
  #
  # @example Bracketize ip_arr input
  #
  #   $foo = [ '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
  #            '2001:0db8:85a3:0000:0000:8a2e:0370:7334/24' ]
  #
  #   $bar = simplib::bracketize($foo)
  #
  #   $bar contains:[ '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
  #                   '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24' ]
  #
  dispatch :bracketize do
    required_param 'Array[String]', :ip_arr
  end

  # @param ipaddr_string The string of IPv6 addresses to bracketize (comma, space, and/or semi-colon separated)
  # @return [Variant[String, Array[String]]] converted input
  #
  # @example Bracketize ipaddr_string input
  #
  #   $foo = '2001:0db8:85a3:0000:0000:8a2e:0370:7334,2001:0db8:85a3:0000:0000:8a2e:0370:7334/24 3456:0db8:85a3:0000:0000:8a2e:0370:7334'
  #
  #   $bar = simplib::bracketize($foo)
  #
  #   $bar contains:[ '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
  #                   '[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/24',
  #                   '[3456:0db8:85a3:0000:0000:8a2e:0370:7334]' ]
  #
  dispatch :bracketize_string_input do
    required_param 'String', :ipaddr_string
  end

  def bracketize_string_input(ipaddr_string)
    ip_arr = ipaddr_string.split(%r{\s|,|;}).delete_if { |y| y.empty? }
    bracketize(ip_arr)
  end

  def bracketize(ip_arr)
    require 'ipaddr'
    ipaddr = Array(ip_arr).flatten
    retval = []
    ipaddr.each do |x|
      begin
        ip = IPAddr.new(x)
      rescue
        # allowed to fail because input can be string of hostname
        # will just return unaltered input in that case
        retval << x
        next
      end
      # IPv6 Address?
      if ip.ipv6?
        if x[0].chr != '['
          y = x.split('/')
          y[0] = "[#{y[0]}]"
          retval << y.join('/')
        else
          retval << x
        end
      else
        retval << x
      end
    end

    retval = retval.first if retval.size == 1
    retval
  end
end
