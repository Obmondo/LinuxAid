#  Transforms an IP address to one or more interval values for `cron`.
#  This can be used to avoid starting a certain cron job at the same
#  time on all servers.
Puppet::Functions.create_function(:'simplib::ip_to_cron') do
  local_types do
    type "IpToCronAlgorithm = Enum['ip_mod', 'sha256']"
  end

  # @param occurs
  #   The occurrence within an interval, i.e., the number of values to
  #   be generated for the interval.
  #
  # @param max_value
  #   The maximum value for the interval.  The values generated will
  #   be in the inclusive range [0, max_value].
  #
  # @param algorithm
  #   When 'ip_mod', the modulus of the IP number is used as the basis
  #   for the returned values.  This algorithm works well to create
  #   cron job intervals for multiple hosts, when the number of hosts
  #   exceeds the `max_value` and the hosts have largely, linearly-
  #   assigned IP addresses.
  #
  #   When 'sha256', a random number generated using the IP address
  #   string is the basis for the returned values.  This algorithm
  #   works well to create cron job intervals for multiple hosts,
  #   when the number of hosts is less than the `max_value` or the
  #   hosts do not have linearly-assigned IP addresses.
  #
  # @param ip
  #   The IP address to use as the basis for the generated values.
  #   When `nil`, the 'networking.ip' fact (IPv4) is used.
  #
  # @return [Array[Integer]] Array of integers suitable for use in the
  #   ``minute`` or ``hour`` cron field.
  #
  # @example Generate one value for the `minute` cron interval
  #   ip_to_cron()
  #
  # @example Generate 2 values for the `hour` cron interval, using the
  #   'sha256' algorithm and a provided IP address
  #
  #   ip_to_cron(2,23,'sha256','10.0.23.45')
  #

  dispatch :ip_to_cron do
    optional_param 'Integer[1]',        :occurs
    optional_param 'Integer[1]',        :max_value
    optional_param 'IpToCronAlgorithm', :algorithm
    optional_param 'Simplib::IP',       :ip
  end

  def ip_to_cron(occurs = 1, max_value = 59, algorithm = 'ip_mod', ip = nil)
    if ip.nil?
      scope = closure_scope
      ipaddr = scope['facts'].dig('networking', 'ip')
    else
      ipaddr = ip.dup
    end

    call_function('simplib::rand_cron', ipaddr, algorithm, occurs, max_value)
  end
end
