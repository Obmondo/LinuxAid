#  Transforms an input string to one or more interval values for `cron`.
#  This can be used to avoid starting a certain cron job at the same
#  time on all servers.

Puppet::Functions.create_function(:'simplib::rand_cron') do
  local_types do
    type "RandCronAlgorithm = Enum['crc32', 'ip_mod', 'sha256']"
  end

  # @param modifier
  #   The input string to use as the basis for the generated values.
  #
  # @param algorithm
  #   Randomization algorithm to apply to transform the input string.
  #
  #   When 'sha256', a random number generated from the input string
  #   via sha256 is used as the basis for the returned values.
  #   If the input string is an IP address, this algorithm works well to
  #   create cron job intervals for multiple hosts, when the number
  #   of hosts is less than the `max_value` or the hosts do not have
  #   linearly-assigned IP addresses.
  #
  #   When 'ip_mod' and the input string is an IP address, the modulus
  #   of the numeric IP is used as the basis for the returned values.
  #   This algorithm works well to create cron job intervals for
  #   multiple hosts, when the number of hosts exceeds the `max_value`
  #   and the hosts have linearly-assigned IP addresses.
  #
  #   When 'ip_mod' and the input string is not an IP address, for
  #   backward compatibility,  the crc32 of the input string will
  #   be used as the basis for the returned values.
  #
  #   When 'crc32', the crc32 of the input string will be used as the
  #   basis for the returned values.
  #
  # @param occurs
  #   The occurrence within an interval, i.e., the number of values to
  #   be generated for the interval. Defaults to `1`.
  #
  # @param max_value
  #   The maximum value for the interval.  The values generated will
  #   be in the inclusive range [0, max_value]. Defaults to `60` for
  #   use in the `minute` cron field.
  #
  # @return [Array[Integer]] Array of integers suitable for use in the
  #   ``minute`` or ``hour`` cron field.
  #
  # @example Generate one value for the `minute` cron interval using
  #   the 'sha256' algorithm
  #
  #   rand_cron('myhost.test.local','sha256')
  #
  # @example Generate 2 values for the `minute` cron interval using
  #   the 'sha256' algorithm applied to the numeric representation of
  #   an IP
  #
  #   rand_cron('10.0.23.45', 'sha256')
  #
  # @example Generate 2 values for the `hour` cron interval, using the
  #   'ip_mod' algorithm
  #
  #   rand_cron('10.0.6.78', 'ip_mod', 2, 23)
  #
  dispatch :rand_cron do
    required_param 'String',            :modifier
    required_param 'RandCronAlgorithm', :algorithm
    optional_param 'Integer[1]',        :occurs
    optional_param 'Integer[1]',        :max_value
  end

  def generate_crc32_number(input_string)
    require 'zlib'
    Zlib.crc32(input_string)
  end

  def generate_ip_mod_number(input_string)
    require 'ipaddr'

    ip_num = nil
    begin
      ip_num = IPAddr.new(input_string).to_i
    rescue IPAddr::Error
      # do nothing
    end
    num = if ip_num.nil?
            # crc32 calculation for backward compatibility
            generate_crc32_number(input_string)
          else
            ip_num
          end
    num
  end

  def generate_sha256_number(input_string)
    require 'digest'

    Digest::SHA256.hexdigest(input_string).hex
  end

  # @param modifier Input string to be transformed to an Integer
  # @param algorithm Algorithm to apply to transform input string into
  #   an Integer
  #
  # @return Integer to be used as a basis for generated cron values
  def generate_numeric_modifier(modifier, algorithm)
    send("generate_#{algorithm}_number", modifier)
  end

  def rand_cron(modifier, algorithm, occurs = 1, max_value = 59)
    range_modifier = generate_numeric_modifier(modifier, algorithm)
    modulus = max_value + 1
    base = range_modifier % modulus

    values = if occurs == 1
               [base]
             else
               (1..occurs).map do |i|
                 ((base - (modulus / occurs * i)) % modulus)
               end
             end
    values.sort
  end
end
