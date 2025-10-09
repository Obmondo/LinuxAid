# Tranforms a list of networks into an equivalent array in
# dotted quad notation.
#
# * IPv4 CIDR networks are converted to dotted quad notation networks.
#   All other IP addresses and hostnames are left untouched.
# * Terminates catalog compilation if any input item is not a
#   valid network or hostname.
#
Puppet::Functions.create_function(:'simplib::nets2ddq') do
  # @param networks The networks to convert
  # @return [Array[String]] Converted input
  # @raise [RuntimeError] if any input item is not a valid network
  #   or hostname
  #
  # @example Convert Array input
  #
  #   $foo = [ '10.0.1.0/24',
  #            '10.0.2.0/255.255.255.0',
  #            '10.0.3.25',
  #            'myhost',
  #            '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
  #            '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64' ]
  #
  #   $bar = simplib::nets2ddq($foo)
  #
  #   $bar contains:[ '10.0.1.0/255.255.255.0',
  #                   '10.0.2.0/255.255.255.0',
  #                   '10.0.3.25',
  #                   'myhost',
  #                   '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
  #                   '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64' ]
  #
  dispatch :nets2ddq do
    required_param 'Array', :networks
  end

  # @param networks_string String containing the list of networks to
  #   convert; list elements are separated by spaces, commas or semicolons.
  # @return [Array[String]] Converted input
  # @raise [RuntimeError] if any input item is not a valid network
  #   or hostname
  #
  # @example Convert String input
  #
  #   $foo = '10.0.1.0/24 10.0.2.0/255.255.255.0 10.0.3.25 myhost 2001:0db8:85a3:0000:0000:8a2e:0370:7334 2001:0db8:85a3:0000:0000:8a2e:0370:7334/64'
  #
  #   $bar = simplib::nets2ddq($foo)
  #
  #   $bar contains:[ '10.0.1.0/255.255.255.0',
  #                   '10.0.2.0/255.255.255.0',
  #                   '10.0.3.25',
  #                   'myhost',
  #                   '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
  #                   '2001:0db8:85a3:0000:0000:8a2e:0370:7334/64' ]
  #
  dispatch :nets2ddq_string_input do
    required_param 'String', :networks_string
  end

  def nets2ddq_string_input(networks_string)
    networks = networks_string.split(%r{\s|,|;}).delete_if { |y| y.empty? }
    nets2ddq(networks)
  end

  def nets2ddq(networks)
    require 'ipaddr'
    require File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')

    retval = []
    networks.each do |lnet|
      begin
        ipaddr = IPAddr.new(lnet)
      rescue
        if PuppetX::SIMP::Simplib.hostname?(lnet)
          retval << lnet
          next
        end
        raise("simplib::nets2ddq(): '#{lnet}' is not a valid network.")
      end

      # Just add it without touching if it is an ipv6 addr
      retval << if ipaddr.ipv6?
                  lnet
                # Just add it if it doesn't have a specified netmask.
                elsif lnet.include?('/')
                  "#{ipaddr}/#{ipaddr.inspect.split('/').last.chop}"
                else
                  lnet
                end
    end
    retval
  end
end
