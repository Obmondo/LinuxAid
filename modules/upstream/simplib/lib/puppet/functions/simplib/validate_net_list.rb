# Validate that a passed list (`Array` or single `String`) of networks
# is filled with valid IP addresses, network addresses (CIDR notation),
# or hostnames.
#
# * Hostnames are checked per RFC 1123.
# * Ports appended with # a colon `:` are allowed for hostnames and
#   individual IP addresses.
# * Terminates catalog compilation if validation fails.
#
Puppet::Functions.create_function(:'simplib::validate_net_list') do

  # @param net Single network to be validated.
  # @param str_match Stringified regular expression (regex without
  #   the `//` delimiters)
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #
  #   $trusted_nets = '10.10.10.0/24'
  #   simplib::validate_net_list($trusted_nets)
  #
  #   $trusted_nets = '1.2.3.5:400'
  #   simplib::validate_net_list($trusted_nets)
  #
  #   $trusted_nets = 'ALL'
  #   simplib::validate_net_list($trusted_nets,'^(%any|ALL)$')
  #
  # @example Failing
  #
  #   $trusted_nets = '10.10.10.0/24,1.2.3.4'
  #   simplib::validate_net_list($trusted_nets)
  #
  #   $trusted_nets = 'bad stuff'
  #   simplib::validate_net_list($trusted_nets)
  #
  dispatch :validate_net do
    required_param 'String', :net
    optional_param 'String', :str_match
  end

  # @param net_list `Array` of networks to be validated.
  # @param str_match Stringified regular expression (regex without
  #   the `//` delimiters)
  # @return [Nil]
  # @raise [RuntimeError] if validation fails
  #
  # @example Passing
  #
  #   $trusted_nets = ['10.10.10.0/24','1.2.3.4','1.3.4.5:400']
  #   simplib::validate_net_list($trusted_nets)
  #
  #   $trusted_nets = '10.10.10.0/24'
  #   simplib::validate_net_list($trusted_nets)
  #
  #   $trusted_nets = ['10.10.10.0/24','1.2.3.4','%any','ALL']
  #   simplib::validate_net_list($trusted_nets,'^(%any|ALL)$')
  #
  # @example Failing
  #
  #   $trusted_nets = ['10.10.10.0/24 1.2.3.4']
  #   simplib::validate_net_list($trusted_nets)
  #
  #   $trusted_nets = 'bad stuff'
  #   simplib::validate_net_list($trusted_nets)
  dispatch :validate_net_list do
    required_param 'Array[String]', :net_list
    optional_param 'String', :str_match
  end

  def validate_net(net, str_match=nil)
    validate_net_list(Array(net), str_match)
  end

  def validate_net_list(net_list, str_match=nil)
    local_net_list = Array(net_list.dup)  # not allowed to modify arguments

    if str_match
      # hack to be backward compatible
      local_str_match = str_match.dup
      local_str_match = '\*' if local_str_match == '*'

      local_str_match = Regexp.new(local_str_match)
      local_net_list.delete_if{|x| local_str_match.match(x)}
    end

    require File.expand_path(File.dirname(__FILE__) + '/../../../puppetx/simp/simplib.rb')
    require 'ipaddr'

    # Needed to use other functions inside of this one
#    Puppet::Parser::Functions.autoloader.loadall

    local_net_list.each do |net|
      # Do we have a port?
      host,port = PuppetX::SIMP::Simplib.split_port(net)
      call_function('simplib::validate_port', port) if (port && !port.empty?)

      # Valid quad-dotted IPv4 addresses will validate as hostnames.
      # So check for IP addresses first
      begin
        IPAddr.new(host)
      # For some reason, can't see derived error class (IPAddr::Error)
      # when run by Puppet
      rescue ArgumentError
        # if looks like quad-dotted set of decimal numbers, most likely
        # it is not an oddly-named host, but a bad IPv4 address in which
        # one or more of the octets is out of range (configuration
        # fat-finger....)
        if host.match(/^([0-9]+)(\.[0-9]+){3}$/)
          fail("simplib::validate_net_list(): '#{net}' is not a valid network.")
        end

        # assume OK if this looks like hostname
        unless PuppetX::SIMP::Simplib.hostname_only?(host)
          fail("simplib::validate_net_list(): '#{net}' is not a valid network.")
        end
      end
    end
  end
end
